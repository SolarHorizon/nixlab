{
  self,
  lib,
  ...
}: let
  domain = "watch.matthewlabs.net";
  host = "monolith";
  port = 8096;
in {
  flake.modules.nixos.jellyfin = {
    config,
    pkgs,
    ...
  }: let
    report = config.hardware.facter.report;

    usesGraphicsDriver = driver:
      builtins.any
      (card: card.driver or "" == driver)
      (report.hardware.graphics_card or []);
  in
    lib.mkMerge [
      (lib.mkIf (usesGraphicsDriver "i915") {
        hardware.graphics = {
          enable = true;
          extraPackages = with pkgs; [
            vpl-gpu-rt
            intel-media-driver
          ];
        };
      })
      (lib.mkIf (usesGraphicsDriver "amdgpu") {
        hardware.graphics = {
          enable = true;
          extraPackages = with pkgs; [
            libva
            mesa
          ];
        };
      })
      {
        services.jellyfin = {
          inherit (config.media-server) group;
          enable = true;
          package = pkgs.unstable.jellyfin;
          openFirewall = true;
        };
      }
    ];

  flake.modules.nixos.caddy-external = self.lib.mkReverseProxy {
    inherit domain host port;
  };

  flake.modules.nixos.${host} = {
    imports = with self.modules.nixos; [
      jellyfin
    ];
  };
}
