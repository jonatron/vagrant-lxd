module VagrantPlugins
  module ProviderLxd
    module Action
      class Network
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::lxd::action::network")
        end

        def call(env)
          ##
          # Right now I ignore all network config for machines and connect
          # them all to a single bridge called vagrantbr0. (Well the name
          # is transparently used and may be changed if necessary.
          #
          env[:bridge] = env[:machine].provider.driver.bridge

          @app.call(env)
        end
      end
    end
  end
end

# vim: set et ts=2 sw=2:
