{inputs, ...}: {
  flake.modules.nixos.sops = {config, ...}: {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];

    sops = {
      age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      defaultSopsFile = ../../secrets/hosts/${config.networking.hostName}.yaml;
    };
  };

  flake.modules.homeManager.sops = {config, ...}: {
    imports = [
      inputs.sops-nix.homeManagerModules.sops
    ];

    sops = {
      age.sshKeyPaths = ["${config.home.homeDirectory}/.ssh/id_ed25519_sops"];
      age.generateKey = true;
      defaultSopsFile = ../../secrets/users/${config.home.username}.yaml;
    };
  };
}
