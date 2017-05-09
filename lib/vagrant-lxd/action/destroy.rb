module VagrantPlugins
  module ProviderLxd
    module Action
      class Destroy
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::lxd::action::destroy")
        end

        def call(env)
          driver = env[:machine].provider.driver

          if driver.container?
            if driver.state == :running
              driver.stop
            end
            driver.destroy
          end

          @app.call(env)
        end
      end
    end
  end
end

# vim: set et ts=2 sw=2:
