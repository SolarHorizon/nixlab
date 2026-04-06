{self, ...}: let
  domain = "home.matt.you";
  host = "192.168.0.142";
  port = 8123;
in {
  flake.modules.nixos.caddy-internal = self.lib.mkReverseProxy {
    inherit domain host port;
  };
}
