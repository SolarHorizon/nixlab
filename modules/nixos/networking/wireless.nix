{
  flake.modules.nixos.wireless = {
    config,
    lib,
    ...
  }: {
    networking.wireless.iwd.enable = true;
    networking.networkmanager.wifi.backend = lib.mkIf config.networking.networkmanager.enable "iwd";
  };
}
