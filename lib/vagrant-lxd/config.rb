module VagrantPlugins
  module ProviderLxd
     class Config < Vagrant.plugin("2", :config)
       def initialize
         @privileged = false
       end

       def privileged
         @privileged = true
       end

       def privileged?
         @privileged
       end
     end
  end
end

# vim: set et ts=2 sw=2:
