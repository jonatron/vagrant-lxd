module VagrantPlugins
  module ProviderLxd
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

          # TODO maybe not optimal, check if it would be better to include the
          # pid of the init process to the id of the machine.
          # Well, in that case the id changes with every restart which might
          # not be feasable...
          env[:machine].id = driver.name

          @app.call(env)
        end
      end
    end
  end
end

# vim: set et ts=2 sw=2:
