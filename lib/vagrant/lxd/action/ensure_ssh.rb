module Vagrant
  module Lxd
    module Action
      class EnsureSsh
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::lxd::action::ensure_started")
        end

        def call(env)
          driver = env[:machine].provider.driver

          env[:ui].info "--- #{env[:machine].box.directory} ---",
            :prefix => false
          driver.vagrant_user
          driver.enable_ssh

          @app.call(env)
        end
      end
    end
  end
end

# vim: set et ts=2 sw=2:
