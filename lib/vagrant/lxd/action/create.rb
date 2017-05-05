module Vagrant
  module Lxd
    module Action
      class Create
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::lxd::action::create")
        end

        def call(env)
          driver = env[:machine].provider.driver

          if driver.container?
            env[:ui].info "--- Container fount ---", :prefix => false
          else
            env[:ui].info "--- Create #{driver.name} ---", :prefix => false
            driver.create
            env[:ui].info "--- #{driver.name} created ---", :prefix => false
          end

          @app.call(env)
        end
      end
    end
  end
end

# vim: set et ts=2 sw=2:
