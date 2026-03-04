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

  flake.modules.homeManager.sops = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      inputs.sops-nix.homeManagerModules.sops
    ];

    home.packages = with pkgs; [
      age
      sops
      ssh-to-age
      ssh-to-pgp
    ];

    sops = {
      age.sshKeyPaths = ["${config.home.homeDirectory}/.ssh/id_ed25519"];
      defaultSopsFile = ../../secrets/users/${config.home.username}.yaml;
    };
  };
}
