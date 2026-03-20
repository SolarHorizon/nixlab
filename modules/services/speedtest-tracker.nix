{self, ...}: let
  host = "monolith";
  domain = "speedtest.matthewlabs.net";
  port = 28082;
  user = "speedtest-tracker";
  uid = 137;
  group = user;
  gid = uid;
in {
  flake.modules.nixos.speedtest-tracker = {config, ...}: {
    sops.secrets."speedtest-tracker/app_key" = {
      sopsFile = ../../secrets/services/speedtest-tracker.yaml;
    };

    sops.templates."speedtest-tracker.env".content = ''
      APP_KEY=${config.sops.placeholder."speedtest-tracker/app_key"}
    '';

    users.groups."${group}".gid = gid;
    users.users."${user}" = {
      isSystemUser = true;
      group = group;
      uid = uid;
    };

    virtualisation.oci-containers.containers.speedtest-tracker = {
      # update to latest later
      image = "lscr.io/linuxserver/speedtest-tracker:1.12.4";
      serviceName = "speedtest-tracker";
      environment = {
        APP_URL = "https://${domain}";
        ASSET_URL = "https://${domain}";
        CHART_DATETIME_FORMAT = "m/j G:i";
        DATETIME_FORMAT = "M j Y, G:i:s";
        DISPLAY_TIMEZONE = config.time.timeZone;
        PGID = toString gid;
        PUID = toString uid;
        SPEEDTEST_SCHEDULE = "0 */4 * * *";
        SPEEDTEST_BLOCKED_SERVERS = builtins.concatStringsSep "," [
          "13429"
        ];
      };
      environmentFiles = [
        config.sops.templates."speedtest-tracker.env".path
      ];
      ports = [
        "${toString port}:80"
      ];
      volumes = [
        "/var/lib/speedtest-tracker:/config"
      ];
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/speedtest-tracker 0755 ${user} ${group} -"
    ];
  };

  flake.modules.nixos.caddy-internal = self.lib.mkReverseProxy {
    inherit domain host port;
  };

  flake.modules.nixos.${host} = {
    imports = with self.modules.nixos; [
      speedtest-tracker
    ];
  };
}
