{
  self,
  lib,
  ...
}: let
  dataDir = "/var/lib/omada";

  host = "monolith";
  domain = "omada.matthewlabs.net";
  manageHttpsPort = 8043;
  manageHttpPort = 8088;
  portalHttpsPort = 8843;
  portalHttpPort = manageHttpPort;

  user = "omada";
  uid = 508;
  group = user;
  gid = uid;
in {
  flake.modules.nixos.omada = {config, ...}: {
    users.users.${user} = {
      inherit uid group;
      isSystemUser = true;
    };

    users.groups.${group} = {
      inherit gid;
    };

    virtualisation.oci-containers.containers.omada-controller = {
      image = "mbentley/omada-controller:6.1";
      environment = {
        TZ = config.time.timeZone;
        PORTAL_HTTPS_PORT = toString portalHttpsPort;
        PORTAL_HTTP_PORT = toString portalHttpPort;
        MANAGE_HTTPS_PORT = toString manageHttpsPort;
        MANAGE_HTTP_PORT = toString manageHttpPort;
        ROOTLESS = "true";
      };
      volumes = [
        "${dataDir}/data:/opt/tplink/EAPController/data"
        "${dataDir}/logs:/opt/tplink/EAPController/logs"
      ];
      extraOptions = [
        "--network=host"
        "--stop-timeout=60"
        "--ulimit=nofile=4096:8192"
        "--user=${toString uid}:${toString gid}"
      ];
    };

    networking.firewall = {
      allowedTCPPorts = lib.unique [
        manageHttpsPort
        manageHttpPort
        portalHttpsPort
        portalHttpPort
        27001 # device discovery
        29811 # device management v1 protocol
        29812 # device adoption v1
        29813 # firmware upgrade notifications v1
        29814 # device management v2 protocol
        29815 # data transfer v2
        29816 # rtty
        29817 # device monitoring
      ];
      allowedUDPPorts = [
        27001 # device discovery
        29810 # device discovery
      ];
    };

    systemd.tmpfiles.rules = [
      "d ${dataDir} 0755 ${user} ${group} -"
      "d ${dataDir}/data 0755 ${user} ${group} -"
      "d ${dataDir}/logs 0755 ${user} ${group} -"
    ];
  };

  flake.modules.nixos.caddy-internal = self.lib.mkReverseProxy {
    inherit domain host;
    port = manageHttpPort;
  };

  flake.modules.nixos.${host} = {
    imports = with self.modules.nixos; [
      omada
    ];
  };
}
