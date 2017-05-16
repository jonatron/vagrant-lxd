# vagrant-lxd

[LXD](https://www.ubuntu.com/containers/lxd) provider for
[Vagrant](http://www.vagrantup.com/) 1.9.3

This is a Vagrant plugin that allows it to control and provision Linux
Containers as an alternative to the built in VirtualBox provider for Linux
hosts.

## Features

* Start and stop LXD managed container.
* No port forwarding right now.
* Uses LXD managed bridge network.

## Requirements

* [Vagrant](http://www.vagrantup.com/downloads.html) (tested with 1.9.3)
* lxd (tested with 2.11)
* All lxd dependencies (especially dnsmasq for LXD managed networking)

I tested the plugin on gentoo, installed via `vagrant plugin install`.

## Installation

As long as is not publicly available at rubygems pleace clone the repo,
Change to the checked out directory ad do:

```
rake build
vagrant plugin install pkg/vagrant-lxd-0.0.1.gem
```

## Boxes

Some example boxes are provided within the example_box directory.

## Configuration

Currently the provider knows only one config option.

```ruby
Vagrant.configure("2") do |config|
  config.vm.provider :lxd do |lxd|
    lxd.privileged
  end
end
```

This will create a privileged instead of an unprivileged container.

### Container naming

The defined VM name will be prefixed with vagrant. At the moment there is
no logic to make them uniqe.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
