{self, ...}: let
  host = "monolith";
  port = 9696;
  domain = "prowlarr.matthewlabs.net";
in {
  flake.modules.nixos.prowlarr = {pkgs, ...}: {
    services.prowlarr = {
      enable = true;
      package = pkgs.unstable.prowlarr;
      openFirewall = true;
    };
  };

  flake.modules.nixos.caddy-internal = self.lib.mkReverseProxy {
    inherit domain host port;
  };

  flake.modules.nixos.${host} = {
    imports = with self.modules.nixos; [
      prowlarr
    ];
  };
}
