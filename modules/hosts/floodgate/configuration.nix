{self, ...}: {
  hosts.nixos.floodgate = {
    autoUpdate.enable = true;
    autoUpdate.strategy = "push";
  };

  flake.modules.nixos.floodgate = {
    imports = with self.modules.nixos; [
      role-server
      grub
      caddy-external
      minecraft
      minecraft-cobbleverse
    ];

    home-manager.sharedModules = with self.modules.homeManager; [
      role-server
    ];

    hardware.facter.reportPath = ./facter.json;

    system.stateVersion = "25.11";

    # TODO: legacy options, check what they're for and refactor
    zramSwap.enable = true;
    services.logrotate.checkConfig = false;
  };
}
