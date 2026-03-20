{self, ...}: let
  domain = "bazarr.matthewlabs.net";
  host = "monolith";
  port = 6767;
in {
  flake.modules.nixos.bazarr = {
    config,
    pkgs,
    ...
  }: {
    services.bazarr = {
      inherit (config.media-server) group;
      enable = true;
      package = pkgs.unstable.bazarr;
      openFirewall = true;
    };
  };

  flake.modules.nixos.caddy-internal = self.lib.mkReverseProxy {
    inherit domain host port;
  };

  flake.modules.nixos.${host} = {
    imports = with self.modules.nixos; [
      bazarr
    ];
  };
}
