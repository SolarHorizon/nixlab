{self, ...}: {
  flake.modules.nixos.floodgate = {
    imports = with self.modules.nixos; [
      profile-cli
      deployment
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

    # TODO: remove when we're sure ssh forwarding works
    security.sudo.wheelNeedsPassword = false;
  };

  flake.nixosConfigurations = self.lib.mkNixos "x86_64-linux" "floodgate";
}
