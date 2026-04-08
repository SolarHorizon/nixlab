let
  dataDir = "/var/lib/vintagestory/server";
  user = "vintagestory";
  uid = 1100;
  group = user;
  gid = uid;
in {
  flake.modules.nixos.vintagestory = {config, ...}: {
    sops.secrets."vintagestory/server_password" = {
      sopsFile = ../../../secrets/services/vintagestory.yaml;
    };

    sops.templates."vintagestory.env" = {
      owner = user;
      content = ''
        VS_CFG_SERVER_PASSWORD=${config.sops.placeholder."vintagestory/server_password"}
      '';
    };

    users.groups."${group}".gid = gid;
    users.users."${user}" = {
      isSystemUser = true;
      group = group;
      uid = uid;
    };

    virtualisation.oci-containers.containers.vintagestory = {
      serviceName = "vintagestory";
      image = "ghcr.io/darkmatterproductions/vintagestory:latest@sha256:ce84922a8e21d71b85cd4941530ba6e15409ecbd007f57d821ffc6f2b01a39dd";
      environment = {
        ENABLE_DEBUG_LOGGING = "true";
        ENABLE_CHAT_LOGGING = "true";
      };
      environmentFiles = [
        config.sops.templates."vintagestory.env".path
      ];
      ports = [
        "42420:42420/udp"
        "42420:42420/tcp"
      ];
      volumes = [
        "${dataDir}:/vintagestory/data"
      ];
    };

    systemd.tmpfiles.rules = [
      "d ${dataDir} 0755 ${user} ${group} -"
    ];
  };
}
