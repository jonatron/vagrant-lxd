require "log4r"

module VagrantPlugins
  module ProviderLxd
    autoload :Driver, File.expand_path("../driver", __FILE__)
    autoload :Action, File.expand_path("../action", __FILE__)

    class Provider < Vagrant.plugin('2', :provider)
      attr_reader :driver

      def initialize(machine)
        @logger = Log4r::Logger.new("vagrant::provider::lxd")
        @machine = machine
        @driver = Driver.new(@machine)
      end

      # Returns the SSH info for accessing the LXD container.
      def ssh_info
        # If the VM is not running that we can't possibly SSH into it
        return nil if state.id != :running

        # Return what we know. The host is always "127.0.0.1" because
        # VirtualBox VMs are always local. The port we try to discover
        # by reading the forwarded ports.
        return {
          host: @driver.ipv4,
          port: "22"
        }
      end

      # Return the state of VirtualBox virtual machine by actually
      # querying VBoxManage.
      #
      # @return [Symbol]
      def state
        # Determine the ID of the state here.
        state_id = @driver.state

        # Translate into short/long descriptions
        short = state_id.to_s.gsub("_", " ")
        long  = I18n.t("vagrant.commands.status.#{state_id}")

        # If we're not created, then specify the special ID flag
        if state_id == :not_created
          state_id = Vagrant::MachineState::NOT_CREATED_ID
        end

        # Return the state
        Vagrant::MachineState.new(state_id, short, long)
      end

      # @see Vagrant::Plugin::V1::Provider#action
      def action(name)
        # Attempt to get the action method from the Action class if it
        # exists, otherwise return nil to show that we don't support the
        # given action.
        action_method = "action_#{name}"
        return Action.send(action_method) if Action.respond_to?(action_method)
        nil
      end

      def to_s
        id = @machine.id ? @machine.id : "new VM"
        "Lxd (#{id})"
      end
    end
  end
end

# vim: set et ts=2 sw=2:
