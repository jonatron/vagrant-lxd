module VagrantPlugins
  module CommandLxd
    class Command < Vagrant.plugin('2', :command)
      # def initialize(argv, env)
      #    super argv, env
      # end

      def execute
        @env.ui.info "my own plugin"
        @env.ui.info "--- #{@env.inspect} ---"
        @env.ui.info "--- #{@local_data_path} ---"
        @env.ui.info "--- #{@env.active_machines} ---"
      end
    end
  end
end

# vim: set et ts=2 sw=2:
