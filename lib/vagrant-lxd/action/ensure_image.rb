module VagrantPlugins
  module ProviderLxd
    module Action
      class EnsureImage
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::lxd::action::ensure_image")
        end

        def call(env)
          box = env[:machine].box
          driver = env[:machine].provider.driver

          env[:ui].info "--- check image for #{env[:machine].name} ---",
            :prefix => false
          if driver.image?
            env[:ui].info "--- Image found ---", :prefix => false
          else
            env[:ui].info "--- Image NOT found (downloading) ---",
              :prefix => false
            driver.get_image("images")
            env[:ui].info "--- Image download done ---", :prefix => false
            # TODO maybe we need to check again if the image really exists
            # now.
          end

          @app.call(env)
        end
      end
    end
  end
end

# vim: set et ts=2 sw=2:
