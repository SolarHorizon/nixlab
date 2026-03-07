{self, ...}: {
  flake.modules.nixos.floodgate = {
    imports = with self.modules.nixos; [
      profile-server
      grub
      caddy
    ];

    home-manager.sharedModules = with self.modules.homeManager; [
      profile-cli
    ];

    system.stateVersion = "25.11";

    # TODO: legacy options, check what they're for and refactor
    zramSwap.enable = true;
    services.logrotate.checkConfig = false;
  };

  flake.nixosConfigurations = self.lib.mkNixos "x86_64-linux" "floodgate";
}
