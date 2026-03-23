{
  self,
  inputs,
  ...
}: {
  hosts.nixos.nomad = {
  };

  flake.modules.nixos.nomad = {
    imports = with self.modules.nixos; [
      inputs.nixos-wsl.nixosModules.default
      role-base
      nix-ld
    ];

    home-manager.sharedModules = with self.modules.homeManager; [
      role-base
    ];

    wsl.enable = true;
    wsl.defaultUser = "matt";
    services.fwupd.enable = false;

    system.stateVersion = "25.11";
    nixpkgs.hostPlatform = "x86_64-linux";
  };
}
