require 'bundler'

begin
  require 'vagrant'
rescue LoadError
  Bundler.require(:default, :development)
end

require 'vagrant/lxd/version'
require 'vagrant/lxd/plugin'
