require 'json'
require 'log4r'

require 'vagrant/action/builder'

module VagrantPlugins
  module ProviderLxd
    module Action
      action_root = Pathname.new(File.expand_path("../action", __FILE__))
      autoload :Bootstrap, action_root.join("bootstrap")
      autoload :Create, action_root.join("create")
      autoload :EnsureImage, action_root.join("ensure_image")
      autoload :EnsureSsh, action_root.join("ensure_ssh")
      autoload :EnsureStarted, action_root.join("ensure_started")
      autoload :Network, action_root.join("network")
      autoload :Stop, action_root.join("stop")
      autoload :Destroy, action_root.join("destroy")

      include Vagrant::Action::Builtin

      # This action boots the VM, assuming the VM is in a state that requires
      # a bootup (i.e. not saved).
      def self.action_up
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsState, :not_created do |env, b2|
            # If the VM is NOT created yet, then do the setup steps
            if env[:result]
              b2.use HandleBox
              b2.use EnsureImage
              b2.use Network
              b2.use Create
              b2.use action_start
              b2.use Bootstrap
              b2.use EnsureSsh
            else
              b2.use action_start
            end
          end
          b.use action_provision
        end
      end

      def self.action_start
        Vagrant::Action::Builder.new.tap do |b|
          b.use EnsureStarted
        end
      end

      def self.action_ssh
        Vagrant::Action::Builder.new.tap do |b|
          b.use SSHExec
        end
      end

      def self.action_halt
        Vagrant::Action::Builder.new.tap do |b|
          b.use Stop
        end
      end

      def self.action_destroy
        Vagrant::Action::Builder.new.tap do |b|
          b.use Destroy
        end
      end

      def self.action_provision
        Vagrant::Action::Builder.new.tap do |b|
          #b.use CheckAccessible
          b.use Provision
        end
      end
    end
  end
end

# vim: set et ts=2 sw=2:
