module VagrantPlugins
  module ProviderLxd
    module Action
      class EnsureSsh
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::lxd::action::ensure_started")
        end

        def call(env)
          driver = env[:machine].provider.driver

          # Currently I suppose this is the same on all linux distributions
          # so it is not configured in the metadata of the box.
          driver.vagrant_user
          driver.enable_ssh

          @app.call(env)
        end
      end
    end
  end
end

# vim: set et ts=2 sw=2:
