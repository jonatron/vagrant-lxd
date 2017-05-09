module Vagrant
  module Lxd
    module Action
      class Stop
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::lxd::action::stop")
        end

        def call(env)
          driver = env[:machine].provider.driver

          if driver.container?
            if driver.state == :running
              driver.stop
            end
          end

          @app.call(env)
        end
      end
    end
  end
end

# vim: set et ts=2 sw=2:
