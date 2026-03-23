{self, ...}: let
  domain = "home.matthewlabs.net";
  host = "192.168.0.142";
  port = 8123;
in {
  flake.modules.nixos.caddy-internal = self.lib.mkReverseProxy {
    inherit domain host port;
  };
}
