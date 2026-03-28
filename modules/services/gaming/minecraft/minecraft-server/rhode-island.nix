{
  flake.modules.nixos.minecraft-rhode-island = {
    lib,
    pkgs,
    ...
  }: let
    voiceChatPort = 24455;
    serverPort = 25565;
  in {
    services.minecraft-servers.servers.rhode-island = {
      enable = true;
      package = pkgs.paperServers.paper-1_21_11;

      serverProperties = {
        motd = "Minecraft Mode";
        server-port = serverPort;
        online-mode = false;
        "query.port" = serverPort;
      };

      symlinks = {
        "plugins/luckperms.jar" = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/Vebnzrzj/versions/OrIs0S6b/LuckPerms-Bukkit-5.5.17.jar";
          hash = "sha256-1bFgo5cag3LMWDW81VXjfBqmHp3TBVmSGl9CGhG/l90=";
        };
        "plugins/name-color.jar" = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/fDTjzia9/versions/GcJl1W2i/namecolor-bukkit-1.11.3.jar";
          hash = "sha256-0kQrssvlxVKZsw4DiPl69vTdBC2lgP6eaJoZprvr0C4=";
        };
        "plugins/voicechat.jar" = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/FeJRj2X0/voicechat-bukkit-2.6.12.jar";
          hash = "sha256-NmorbGYVikvidOcCZ80UVIagdUUnpauwTKtQBRGf//w=";
        };
      };
      files = {
        "allowed_symlinks.txt".value = ["/nix/store"];
        "plugins/voicechat/voicechat-server.properties".value = {
          port = voiceChatPort;
          max_voice_distance = 48.0;
          whisper_distance = 24.0;
          codec = "VOIP";
          mtu_size = 1024;
          keep_alive = 1000;
          enable_groups = true;
          allow_recording = true;
          spectator_interaction = false;
          spectator_player_possession = false;
          force_voice_chat = false;
          login_timeout = 10000;
          broadcast_range = -1.0;
          allow_pings = true;
        };
      };

      jvmOpts = lib.concatStringsSep " " [
        "-Xmx8G"
        "-Xms4G"
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

    networking.firewall.allowedUDPPorts = [voiceChatPort];
  };
}
