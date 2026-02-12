{self, ...}: {
  flake.modules.nixos.wireless = {
    imports = [
      self.modules.nixos.networking
    ];

    networking.wireless.iwd.enable = true;
    networking.networkmanager.wifi.backend = "iwd";
  };
}
