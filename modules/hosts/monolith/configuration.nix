{self, ...}: {
  hosts.nixos.monolith = {
    autoUpdate.enable = true;
    autoUpdate.strategy = "push";
  };

  flake.modules.nixos.monolith = {
    imports = with self.modules.nixos; [
      profile-server
      systemd-boot
      media-server
      caddy-internal
      minecraft
      vintagestory
      valheim-server
    ];

    home-manager.sharedModules = with self.modules.homeManager; [
      profile-server
    ];

    system.stateVersion = "24.05";
  };
}
