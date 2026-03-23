{self, ...}: {
  hosts.nixos.nomad = {
  };

  flake.modules.nixos.floodgate = {
    imports = with self.modules.nixos; [
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
  };
}
