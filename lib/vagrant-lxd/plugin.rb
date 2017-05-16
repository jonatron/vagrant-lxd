##
# Test with something like:
#  ~> bundle exec vagrant ls
#
module VagrantPlugins
  module ProviderLxd
    class Plugin < Vagrant.plugin('2')
      name "Lxd"

      description <<-DESC
          Vagrant LXD provider
      DESC

      provider(:lxd, priority: 7) do
        require File.expand_path("../provider", __FILE__)
        Provider
      end

      config(:lxd, :provider) do
        require File.expand_path("../config", __FILE__)
        Config
      end

      #synced_folder(:virtualbox) do
      #  require File.expand_path("../synced_folder", __FILE__)
      #  SyncedFolder
      #end

      #command 'ls' do
      #  require File.expand_path("../command", __FILE__)
      #  Command
      #end

      autoload :Action, File.expand_path("../action", __FILE__)
    end
  end
end

# vim: set et ts=2 sw=2:
