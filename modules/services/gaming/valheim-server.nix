let
  dataPath = "/var/lib/valheim-server";
  user = "valheim";
  uid = 5058;
  group = user;
  gid = uid;
in {
  flake.modules.nixos.valheim-server = {config, ...}: {
    sops.secrets."valheim/server_password" = {
      sopsFile = ../../../secrets/services/valheim-server.yaml;
    };

    sops.templates."valheim-server.env" = {
      owner = user;
      content = ''
        SERVER_PASS=${config.sops.placeholder."valheim/server_password"}
      '';
    };

    users.groups."${group}".gid = gid;
    users.users."${user}" = {
      isSystemUser = true;
      group = group;
      uid = uid;
    };

    virtualisation.oci-containers.containers.valheim-server = {
      serviceName = "valheim-server";
      image = "ghcr.io/lloesche/valheim-server:latest";
      environment = {
        SERVER_NAME = "friends club";
        WORLD_NAME = "friendclubland";
        SERVER_ARGS = "-crossplay";
        SERVER_PUBLIC = "false";
        PUID = toString uid;
        PGID = toString gid;
        TZ = config.time.timeZone;
      };
      environmentFiles = [
        config.sops.templates."valheim-server.env".path
      ];
      ports = [
        "2456-2457:2456-2457/udp"
      ];
      volumes = [
        "${dataPath}/config:/config"
        "${dataPath}/data:/opt/valheim"
      ];
    };

    systemd.tmpfiles.rules = [
      "d ${dataPath} 0755 ${user} ${group} -"
      "d ${dataPath}/config 0755 ${user} ${group} -"
      "d ${dataPath}/data 0755 ${user} ${group} -"
    ];
  };
}
