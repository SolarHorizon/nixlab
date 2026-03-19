{self, ...}: {
  hosts.nixos.framework = {
    # autoUpdate.enable = true;
    # autoUpdate.strategy = "pull";
  };

  flake.modules.nixos.framework = {
    imports = with self.modules.nixos; [
      profile-kde
      wireless
      limine
      yubikey-auto-lock
    ];

    home-manager.sharedModules = with self.modules.homeManager; [
      profile-kde
    ];

    services.fprintd.enable = false;

    system.stateVersion = "25.05";
  };

  #flake.nixosConfigurations = self.lib.mkNixos "x86_64-linux" "framework";
}
