{self, ...}: {
  hosts.nixos.framework = {
    # autoUpdate.enable = true;
    # autoUpdate.strategy = "pull";
  };

  flake.modules.nixos.framework = {
    imports = with self.modules.nixos; [
      role-kde
      limine
      yubikey-auto-lock
    ];

    home-manager.sharedModules = with self.modules.homeManager; [
      role-kde
    ];

    services.fprintd.enable = false;

    networking.wireless.iwd.enable = true;
    networking.networkmanager.wifi.backend = "iwd";

    system.stateVersion = "25.05";
  };

  #flake.nixosConfigurations = self.lib.mkNixos "x86_64-linux" "framework";
}
