{lib, ...}: {
  flake.modules.nixos.omada = {config, ...}: let
    dataPath = "/var/lib/omada";

    manageHttpsPort = 8043;
    manageHttpPort = 8088;
    portalHttpsPort = 8843;
    portalHttpPort = manageHttpPort;

    uid = 508;
    user = "omada";

    gid = uid;
    group = user;
  in {
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
        "${dataPath}/data:/opt/tplink/EAPController/data"
        "${dataPath}/logs:/opt/tplink/EAPController/logs"
      ];
      extraOptions = [
        "--network=host"
        "--stop-timeout=60"
        "--ulimit nofile=4096:8192"
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
      "d ${dataPath} 0755 ${user} ${group} -"
      "d ${dataPath}/data 0755 ${user} ${group} -"
      "d ${dataPath}/logs 0755 ${user} ${group} -"
    ];
  };
}
