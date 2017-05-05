module Vagrant
  module Lxd
    class Command < Vagrant.plugin('2', :command)
      # def initialize(argv, env)
      #    super argv, env
      # end

      def execute
        @env.ui.info("my own plugin", :prefix => false)
      end
    end
  end
end

# vim: set et ts=2 sw=2:
