{self, ...}: {
  flake.modules.nixos.framework = {
    imports = with self.modules.nixos; [
      profile-kde
      wireless
      limine
    ];

    home-manager.sharedModules = with self.modules.homeManager; [
      profile-kde
    ];

    system.stateVersion = "25.05";
  };

  flake.nixosConfigurations = self.lib.mkNixos "x86_64-linux" "framework";
}
