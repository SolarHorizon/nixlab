{self, ...}: let
  domain = "anchorr.matthewlabs.net";
  host = "monolith";
  port = 8282;
  portStr = toString port;
in {
  flake.modules.nixos.anchorr = {
    virtualisation.oci-containers.containers.anchorr = {
      image = "docker.io/nairdah/anchorr:latest";
      serviceName = "anchorr";
      environment = {
        WEBHOOK_PORT = portStr;
        NODE_ENV = "production";
      };
      ports = ["${portStr}:${portStr}"];
      volumes = [
        "/var/lib/anchorr/config:/usr/src/app/config"
      ];
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/anchorr/config 0755 root root -"
    ];
  };

  flake.modules.nixos.caddy-internal = self.lib.mkReverseProxy {
    inherit domain host port;
  };

  flake.modules.nixos.${host} = {
    imports = with self.modules.nixos; [
      anchorr
    ];
  };
}
