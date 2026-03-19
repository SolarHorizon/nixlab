{
  flake.modules.nixos.vintagestory = let
    dataPath = "/var/lib/vintagestory/server";
  in {
    virtualisation.oci-containers.containers.vintagestory-server = {
      serviceName = "vintagestory-server";
      image = "ghcr.io/darkmatterproductions/vintagestory:latest";
      environment = {
        ENABLE_DEBUG_LOGGING = "true";
        ENABLE_CHAT_LOGGING = "true";
      };
      ports = [
        "42420:42420/udp"
        "42420:42420/tcp"
      ];
      volumes = [
        "${dataPath}:/vintagestory/data"
      ];
    };

    systemd.tmpfiles.rules = [
      "d ${dataPath} 0755 root root -"
    ];
  };
}
