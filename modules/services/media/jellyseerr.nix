{self, ...}: let
  domain = "request.matthewlabs.net";
  host = "monolith";
  port = 5055;
in {
  flake.modules.nixos.jellyseerr = {pkgs, ...}: {
    services.jellyseerr = {
      enable = true;
      package = pkgs.unstable.jellyseerr;
      openFirewall = true;
    };
  };

  flake.modules.nixos.caddy-internal = self.lib.mkReverseProxy {
    inherit domain host port;
  };

  flake.modules.nixos.${host} = {
    imports = with self.modules.nixos; [
      jellyseerr
    ];
  };
}
