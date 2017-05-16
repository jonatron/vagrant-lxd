# Vagrant LXD Example Boxe

## Vagrant box format

Vagrant providers each require a custom provider-specific box format.
Here are some examples of boxes for the `lxd` provider.

## The `lxd` box format

The `lxd` provider right now just uses the default lxd images provided
by the lxd images: remote. Upon start these will be provisioned with an
vagrant ssh user and the unsafe common pubkey of vagrant and
sshd will be enabled. All the necessary commands are defined in the
metadata.json file.

## Bootstraped provisioners

The boxes here are prepared to run with the ansible provisioner.
