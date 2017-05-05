module Vagrant
  module Lxd
    module Action
      class EnsureStarted
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::lxd::action::ensure_started")
        end

        def call(env)
          driver = env[:machine].provider.driver

          if driver.state != :running
            env[:ui].info "--- start #{driver.name} ---",
              :prefix => false
            driver.start
            env[:ui].info "--- #{driver.name} started ---",
              :prefix => false
          else
            env[:ui].info "--- #{driver.name} alreay running ---",
              :prefix => false
          end

          @app.call(env)
        end
      end
    end
  end
end

# vim: set et ts=2 sw=2:
