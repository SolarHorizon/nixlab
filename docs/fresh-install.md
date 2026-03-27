# Fresh Install

Adding a new host to this config.

## Steps

### 1. Install NixOS

Either:

- **nixos-anywhere** (preferred): Boot the target into a live environment with SSH access, then run `nix run github:nix-community/nixos-anywhere -- --flake .#<hostname> root@<ip>` from this repo. Generate hardware config with `nixos-facter` on the target and add the report to the host's module. See [nixos-anywhere docs](https://github.com/nix-community/nixos-anywhere).
- **ISO installer**: Minimal install, then replace the config with this repo after.

### 2. Get the host's age public key

Secrets are managed with [sops-nix](https://github.com/Mic92/sops-nix) using each host's SSH host key. Convert it to an age key:

```sh
ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
```

### 3. Add the key to `.sops.yaml` and re-encrypt

Add the age public key to `.sops.yaml` under the new host, then re-encrypt:

```sh
sops updatekeys secrets/hosts/<hostname>.yaml
```

### 4. Copy the sops deploy key

Copy `id_ed25519_sops` to `~/.ssh/id_ed25519_sops` on the new machine. Needed for initial secret decryption during rebuild.

### 5. Rebuild

```sh
sudo nixos-rebuild switch --flake .#<hostname>
```
