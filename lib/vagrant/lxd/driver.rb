##
# Probably useful lxc commands
# - get mac address:
#    lxc config get <container> volatile.eth0.hwaddr
# - get a json formated list of containers:
#    lxc list --format=json -c ns4tS,volatile.eth0.hwaddr:MAC
#   It seems that -c is ignored when json is user so:
#    lxc list --format=json
#   We care only about local containers... so ignore the remote.
#   We might only want to list specific container started by vagrant, thus we
#   should prefix each container name by the term 'vagrant_' and list only
#   containers matching that pattern.
#    lxc list vagrant- --format=json
# - The json above also seems to hold all the config information, anyway
#   another way to show all config values for a given container in a more
#   human readable form is:
#    lxc config show <container>
# - Box/Image management is completely integrated with lxd. All image commands
#   are:
#    lxc image <something>
#   The only thing we might need to keep information over is the image name or
#   id to be used... here a remote might also be useful, to be able to use
#   different image sources. But probably our box files will be quite simple.
#   Anyway, i have not now completely figured out how box files work.
#
# This is pretty much all for now.... start, stop, init, etc. are left for
# later.
# One other thought... it might or might not be a good idea to connect all
# vagrant vms to the same bridge interface created by vagrant... anyway this
# should be configurable in some way.
#
# test this with e.g.:
#  ~> bundel exec irb
#  irb(main):001:0> load 'lxd.rb'
#  => true
#  irb(main):002:0> Vagrant::Lxd::Driver.new('vagrant-gentoo').vmdata
#
# General note: use pp to make the hash human readable.
#
# Network related commands:
#
# - Create a bridged network:
#    lxc network create vagrantbr0
#   Another example:
#    lxc network create vagrantbr0 ipv6.address=none ipv4.address=10.0.3.1/24 ipv4.nat=true
# - Attach network to container:
#    lxc network attach vagrantbr0 <container> default eth0
#
# Further things... right now gentoo specific
#
# - Create vagrant user:
#    lxc exec <container> -- useradd vagrant
# - Set password:
#    lxc exec <container> -- chpasswd <<<vagrant:vagrant
# - Enable sshd service:
#    lxc exec <container> -- rc-update add sshd default
# - Start sshd service manually:
#    lxc exec <container> -- /etc/init.d/sshd start
#
require 'json'
require 'log4r'
require 'yaml'

require 'vagrant/util/retryable'

module Vagrant
  module Lxd
    class Driver
      include Vagrant::Util::Retryable

      attr_reader :name

      def initialize(machine)
        @machine = machine
        @name = "vagrant-#{machine.config.vm.hostname}"
        @name = "vagrant-#{machine.name}" unless @name
        @logger = Log4r::Logger.new("vagrant::provider::lxd::driver")

        # This flag is used to keep track of interrupted state (SIGINT)
        @interrupted = false
        bridge
      end

      # Get all available images and their aliases
      def images
        data = JSON.parse(execute("image", "list", "--format=json"))
        Hash[data.collect do |d|
          d["aliases"].collect { |d2| [d2["name"], d] }
        end.flatten(1)]
      end

      def image
        @machine.box.name.split("/")[1..-1].join("/") if @machine.box
      end

      def image?
        images.key? image
      end

      # Get infos about all existing containers
      def containers
        data = JSON.parse(execute("list", "--format=json"))
        Hash[data.collect { |d| [d["name"], d] }]
      end

      def container?
        containers.key? @name
      end

      # This one will get infos about the managed container.
      def container_data
        containers[@name]
      end

      def network
        container_data["state"]["network"]
      end

      def ipv4
        network["eth0"]["addresses"].select do |d|
          d["family"] == "inet"
        end[0]["address"]
      end

      def state
        return :not_created if not container?
        return :stopped if not container_data["state"]
        container_data["state"]["status"].downcase.to_sym
      end

      def stop
        execute "stop", @name
      end

      def destroy
        execute "delete", @name
      end

      def get_image(remote)
        return if image? # image already exists

        args = [
          "image",
          "copy",
          "#{remote}:#{image}",
          "local:",
          "--copy-aliases"
        ]

        execute(*args)
      end

      def create
        # network could be also attached right here if it turns out to be
        # a good idea.
        execute("init", image, @name, "-n", @bridge["name"])
      end

      def start
        if state != :runnning
          execute("start", @name)
        end
      end

      def bridge
        while not @bridge do
          begin
            @bridge = YAML.load(execute("network", "show", "vagrantbr0"))
          rescue
            execute("network", "create", "vagrantbr0", "dns.mode=dynamic")
          end
        end
        @bridge
      end

      def restart
          execute("stop", @name)
          execute("start", @name)
      end

      def vagrant_user
        pwent = []
        while pwent.empty? do
          begin
            pwent = exec("getent", "passwd", "vagrant").split(":")
          rescue
            exec("useradd", "-m", "-s", "/bin/bash", "vagrant")
          end
        end
        execute(
          "file",
          "push",
          "--uid=#{pwent[2]}",
          "--gid=#{pwent[3]}",
          "--mode=0400",
          "-p",
          "#{@machine.box.directory}/vagrant.pub",
          "#{@name}#{pwent[5]}/.ssh/authorized_keys"
        )
        exec("chmod", "700", "#{pwent[5]}/.ssh")
      end

      def enable_ssh
        #begin
          service = @machine.box.metadata["bootstrap"]["sshd_service"]
          service["exec"].each { |command| exec(*command) }
        #rescue
        #end
      end

      def exec(*command)
        execute("exec", @name, "--", *command)
      end

      # Taken from Virtualbox provider and modified in some parts.
      # Execute the given subcommand for Lxc and return the output.
      def execute(*command, &block)
        # Get the options hash if it exists
        opts = {}
        opts = command.pop if command.last.is_a?(Hash)

        tries = 0
        tries = 3 if opts[:retryable]

        # Variable to store our execution result
        r = nil

        # Most probably retrying is of no use here... if the command does not
        # work it most likely will not work for the second time anyway...
        # I leave this because I guess that vagrant tries commands even it the
        # container is not up and running at the current time.
        retryable(on: Vagrant::Errors::ProviderNotUsable, tries: tries, sleep: 1) do
          # Execute the command
          r = raw(*command, &block)

          # If the command was a failure, then raise an exception that is
          # nicely handled by Vagrant.
          if r.exit_code != 0
            if @interrupted
              @logger.info("Exit code != 0, but interrupted. Ignoring.")
            else
              raise Vagrant::Errors::ProviderNotUsable,
                provider: 'lxd',
                machine: @machine.name,
                message: "\"#{command.inspect}\" failed",
                command: command.inspect,
                stderr: r.stderr,
                stdout: r.stdout
            end
          end
        end

        # Return the output, making sure to replace any Windows-style
        # newlines with Unix-style.
        r.stdout.gsub("\r\n", "\n")
      end

      # Executes a command and returns the raw result object.
      def raw(*command, &block)
        int_callback = lambda do
          @interrupted = true

          # We have to execute this in a thread due to trap contexts
          # and locks.
          Thread.new { @logger.info("Interrupted.") }.join
        end

        # Append in the options for subprocess
        command << { notify: [:stdout, :stderr] }

        Vagrant::Util::Busy.busy(int_callback) do
          Vagrant::Util::Subprocess.execute('lxc', *command, &block)
        end
      rescue Vagrant::Util::Subprocess::LaunchError => e
        raise Vagrant::Errors::ProviderNotUsable,
          message: e.to_s
      end
    end
  end
end

# vim: set et ts=2 sw=2:
