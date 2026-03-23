1. Install NixOS
2. Get the new host's age public key: ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
3. Add it to .sops.yaml and re-encrypt host secrets: sops updatekeys secrets/hosts/<hostname>.yaml
4. Copy id_ed25519_sops to ~/.ssh/id_ed25519_sops on the new machine
5. Rebuild
