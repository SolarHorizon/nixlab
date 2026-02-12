{self, ...}: {
  flake.modules.nixos.framework = {
    imports = with self.modules.nixos; [
      profile-kde
      wireless
      limine
      matt
    ];

    services.fprintd.enable = true;

    system.stateVersion = "25.05";
  };

  flake.nixosConfigurations = self.lib.mkNixos "x86_64-linux" "framework";
}
