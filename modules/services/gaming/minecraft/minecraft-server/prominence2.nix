{inputs, ...}: {
  flake.modules.nixos.minecraft-prominence2 = {
    lib,
    pkgs,
    ...
  }: let
    inherit (inputs.nix-minecraft.lib) collectFilesAt;

    modpack = pkgs.fetchzip {
      url = "https://mediafilez.forgecdn.net/files/6840/824/Prominence_II_Hasturian_Era_3.1.53hf2_Server_Pack.zip";
      hash = "sha256-hJR2Uz4cuJnV/qdjn6iM9QnUA6OhoV7k3+UjuPhSaWg=";
      stripRoot = false;
    };
  in {
    services.minecraft-servers.servers.prominence2 = {
      enable = true;
      package = pkgs.fabricServers.fabric-1_20_1.override {
        loaderVersion = "0.16.14";
      };

      symlinks =
        collectFilesAt modpack "mods"
        // {
          "mods/chunky.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/fALzjamp/versions/NHWYq9at/Chunky-1.3.146.jar";
            hash = "sha256-rn+501o6nZ1PIQSurnsxqQHF5YQokeLt2d3MQsJkajg=";
          };
          "mods/chunky-player-pause.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/wYO04fON/versions/4QMoZ8ZF/chunky-player-pause-1.0.0.jar";
            hash = "sha256-RWEfOJQ4tZ65UH44cd3sL01PlqvOr5HCqSPqgeDDTug=";
          };
          "mods/fabric-proxy-lite.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/8dI2tmqs/versions/XJmDAnj5/FabricProxy-Lite-2.6.0.jar";
            hash = "sha256-1HGReTU9eQRTBhwUtBSJlP9DGsV6EmVVswCc6adI1sc=";
          };
          "mods/cross-stitch.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/YkOyn1Pn/versions/dJioNlO8/crossstitch-0.1.6.jar";
            hash = "sha256-z1qsXFV5sc6xsr0loV8eLcySJvV2cBY60fhBsvkFuC4=";
          };
          "mods/voicechat.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/4DG7BvdF/voicechat-fabric-1.20.1-2.5.35.jar";
            hash = "sha256-13Yh+5MndkUKY5Ieda08ujJzdlIdWpmrAm1tMNlkWJM=";
          };
        };
      files =
        collectFilesAt modpack "config"
        // collectFilesAt modpack "schematics"
        // {
          "allowed_symlinks.txt".value = ["/nix/store"];
          "defaultconfigs" = "${modpack}/defaultconfigs";
          "modernfix" = "${modpack}/modernfix";

          "FabricProxy-Lite.toml".value = {
            hackOnlineMode = true;
            hackEarlySend = false;
            hackMessageChain = true;
            secret = "@forwardingSecret@";
          };

          # errors on read-only filesystems
          "mods/simplyswords-1.56.0-1.20.1.jar" = "${modpack}/mods/simplyswords-1.56.0-1.20.1.jar";
        };

      jvmOpts = lib.concatStringsSep " " [
        "-Xmx20G"
        "-Xms8G"
        "-XX:+UnlockExperimentalVMOptions"
        "-XX:+UseG1GC"
        "-XX:MaxGCPauseMillis=130"
        "-XX:+ParallelRefProcEnabled"
        "-XX:+DisableExplicitGC"
        "-XX:+AlwaysPreTouch"
        "-XX:G1NewSizePercent=28"
        "-XX:G1HeapRegionSize=16M"
        "-XX:G1ReservePercent=20"
        "-XX:InitiatingHeapOccupancyPercent=10"
        "-XX:SurvivorRatio=32"
        "-XX:MaxTenuringThreshold=1"
      ];
    };

    networking.firewall.allowedUDPPorts = [24454];
  };
}
