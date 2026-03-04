{
  flake.modules.nixos.tailscale = {
    lib,
    config,
    ...
  }:
    lib.mkMerge [
      {
        services.tailscale.enable = true;
      }
      (lib.mkIf (config.networking.nftables.enable) {
        networking.firewall = {
          trustedInterfaces = ["tailscale0"];
          allowedUDPPorts = [config.services.tailscale.port];
        };

        systemd = {
          services.tailscaled.serviceConfig.Environment = [
            "TS_DEBUG_FIREWALL_MODE=nftables"
          ];
          network.wait-online.enable = false;
        };

        boot.initrd.systemd.network.wait-online.enable = false;
      })
    ];
}
