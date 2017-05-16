# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-lxd/version'

Gem::Specification.new do |spec|
  spec.name          = "vagrant-lxd"
  spec.version       = VagrantPlugins::ProviderLxd::VERSION
  spec.authors       = ["Georg Hopp"]
  spec.email         = ["georg@steffers.org"]
  spec.license       = 'GPLv3'

  spec.summary       = %q{Vagrant LXD provider.}
  spec.homepage      = "https://gitlab.weird-web-workers.org/ghopp/vagrant-lxd"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
