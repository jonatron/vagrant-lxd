require 'erb'

module VagrantPlugins
  module ProviderLxd
    module Action
      class Bootstrap
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant::lxd::action::bootstrap")
        end

        def call(env)
          driver = env[:machine].provider.driver
          bs_data = env[:machine].box.metadata["bootstrap"]

          bs_data.each do |name, actions|
            env[:ui].info "--- Bootstrap #{name} ---", :prefix => false
            actions.each do |action, data|
              # right now I do not handle differnet actions just return if
              # action is not "exec".
              next if action != "exec"

              container = driver.name
              hostname = env[:machine].name
              data.each do |d|
                d.collect! { |element| ERB.new(element).result(binding) }
                env[:ui].info "--- #{action}: #{d.inspect} ---",
                  :prefix => false
                driver.exec(*d, :retryable => true)
              end
            end
          end
          driver.restart

          @app.call(env)
        end
      end
    end
  end
end

# vim: set et ts=2 sw=2:
