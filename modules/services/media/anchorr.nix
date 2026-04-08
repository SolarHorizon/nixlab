{self, ...}: let
  domain = "anchorr.matt.you";
  host = "monolith";
  port = 8282;
  portStr = toString port;
in {
  flake.modules.nixos.anchorr = {
    virtualisation.oci-containers.containers.anchorr = {
      image = "docker.io/nairdah/anchorr:latest@sha256:27092fe19d166ebeb73d97374d17678324bd901850a8806e2de3a97e91e683a2";
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
