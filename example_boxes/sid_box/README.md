# Vagrant LXD Example Box

Vagrant providers each require a custom provider-specific box format.
This folder shows the example contents of a box for the `lxd` provider.
To turn this into a box:

```
$ tar cvzf lxd.box ./metadata.json ./vagrant.pub
```

The `lxd` provider right now just uses the default lxd images provided
by the lxd images: remote. Upon start these will be provisioned with an
vagrant ssh user and the unsafe common pubkey of vagrant and
sshd will be enabled.
