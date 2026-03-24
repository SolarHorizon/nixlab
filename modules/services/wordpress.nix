{
  self,
  lib,
  ...
}: let
  host = "floodgate";
  domain = "solarhorizon.dev";
  port = 8880;
  dataDir = "/var/lib/wordpress";
in {
  flake.modules.nixos.wordpress = {
    pkgs,
    config,
    ...
  }: {
    # Enable container name DNS for all Podman networks.
    networking.firewall.interfaces = let
      matchAll =
        if !config.networking.nftables.enable
        then "podman+"
        else "podman*";
    in {
      "${matchAll}".allowedUDPPorts = [53];
    };

    # Containers
    virtualisation.oci-containers.containers."wordpress-db" = {
      image = "mariadb:11";
      environment = {
        MARIADB_DATABASE = "wordpress";
        MARIADB_USER = "wordpress";
      };
      environmentFiles = [
        config.sops.templates."wordpress.env".path
      ];
      volumes = [
        "wordpress_db_data:/var/lib/mysql:rw"
      ];
      log-driver = "journald";
      extraOptions = [
        "--network-alias=db"
        "--network=wordpress_default"
      ];
    };

    virtualisation.oci-containers.containers."wordpress-wordpress" = {
      image = "wordpress:6-apache";
      environment = {
        WORDPRESS_DB_HOST = "db";
        WORDPRESS_DB_NAME = "wordpress";
        WORDPRESS_DB_USER = "wordpress";
      };
      environmentFiles = [
        config.sops.templates."wordpress.env".path
      ];
      volumes = [
        "wordpress_wordpress_data:/var/www/html:rw"
      ];
      ports = [
        "127.0.0.1:${toString port}:80/tcp"
      ];
      dependsOn = [
        "wordpress-db"
      ];
      log-driver = "journald";
      extraOptions = [
        "--network-alias=wordpress"
        "--network=wordpress_default"
      ];
    };

    # Systemd service overrides
    systemd.services."podman-wordpress-db" = {
      serviceConfig.Restart = lib.mkOverride 90 "always";
      after = [
        "podman-network-wordpress_default.service"
        "podman-volume-wordpress_db_data.service"
      ];
      requires = [
        "podman-network-wordpress_default.service"
        "podman-volume-wordpress_db_data.service"
      ];
      partOf = ["podman-compose-wordpress-root.target"];
      wantedBy = ["podman-compose-wordpress-root.target"];
    };

    systemd.services."podman-wordpress-wordpress" = {
      serviceConfig.Restart = lib.mkOverride 90 "always";
      after = [
        "podman-network-wordpress_default.service"
        "podman-volume-wordpress_wordpress_data.service"
      ];
      requires = [
        "podman-network-wordpress_default.service"
        "podman-volume-wordpress_wordpress_data.service"
      ];
      partOf = ["podman-compose-wordpress-root.target"];
      wantedBy = ["podman-compose-wordpress-root.target"];
    };

    # Network
    systemd.services."podman-network-wordpress_default" = {
      path = [pkgs.podman];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStop = "podman network rm -f wordpress_default";
      };
      script = ''
        podman network inspect wordpress_default || podman network create wordpress_default
      '';
      partOf = ["podman-compose-wordpress-root.target"];
      wantedBy = ["podman-compose-wordpress-root.target"];
    };

    # Volumes
    systemd.services."podman-volume-wordpress_db_data" = {
      path = [pkgs.podman];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        podman volume inspect wordpress_db_data || podman volume create wordpress_db_data --driver=local --opt=device=${dataDir}/db --opt=o=bind --opt=type=none
      '';
      partOf = ["podman-compose-wordpress-root.target"];
      wantedBy = ["podman-compose-wordpress-root.target"];
    };

    systemd.services."podman-volume-wordpress_wordpress_data" = {
      path = [pkgs.podman];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        podman volume inspect wordpress_wordpress_data || podman volume create wordpress_wordpress_data --driver=local --opt=device=${dataDir}/html --opt=o=bind --opt=type=none
      '';
      partOf = ["podman-compose-wordpress-root.target"];
      wantedBy = ["podman-compose-wordpress-root.target"];
    };

    # Root target — start/stop all WordPress resources together
    systemd.targets."podman-compose-wordpress-root" = {
      unitConfig.Description = "WordPress podman-compose target";
      wantedBy = ["multi-user.target"];
    };

    # Secrets
    sops.secrets."wordpress/db_password" = {
      sopsFile = ../../secrets/services/wordpress.yaml;
    };

    sops.templates."wordpress.env".content = ''
      MARIADB_ROOT_PASSWORD=${config.sops.placeholder."wordpress/db_password"}
      MARIADB_PASSWORD=${config.sops.placeholder."wordpress/db_password"}
      WORDPRESS_DB_PASSWORD=${config.sops.placeholder."wordpress/db_password"}
    '';

    # Data directories
    systemd.tmpfiles.rules = [
      "d ${dataDir} 0755 root root -"
      "d ${dataDir}/db 0755 root root -"
      "d ${dataDir}/html 0755 root root -"
    ];
  };

  flake.modules.nixos.caddy-external = self.lib.mkReverseProxy {
    inherit domain port;
    host = "127.0.0.1";
  };

  flake.modules.nixos.${host} = {
    imports = with self.modules.nixos; [
      wordpress
    ];
  };
}
