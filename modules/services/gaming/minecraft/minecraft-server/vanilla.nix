{
  flake.modules.nixos.minecraft-vanilla = {
    lib,
    pkgs,
    ...
  }: let
    voiceChatPort = 24455;
    serverPort = 25566;
  in {
    services.minecraft-servers.servers.vanilla = {
      enable = true;
      package = pkgs.paperServers.paper-1_21_8;

      serverProperties = {
        motd = "Minecraft Mode";
        server-port = serverPort;
        online-mode = false;
        "query.port" = serverPort;
      };

      symlinks = {
        "plugins/luckperms.jar" = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/Vebnzrzj/versions/ZPtLedoF/LuckPerms-Bukkit-5.5.0.jar";
          hash = "sha256-YoeM1VWJo+H7R2UxoXN8cc0VrGK/C0XwPQKRMTSluwA=";
        };
        "plugins/name-color.jar" = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/fDTjzia9/versions/HecwZPmW/namecolor-bukkit-1.11.jar";
          hash = "sha256-+5ErUYo87B8SC0rtn7XZFkh4+EAAr9itoAC07JFdrkI=";
        };
        "plugins/chunky.jar" = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/fALzjamp/versions/P3y2MXnd/Chunky-Bukkit-1.4.40.jar";
          hash = "sha256-KlR3/ID3EBLhWt4c402+uDbhdiOyjbESSSwPFEPAlyE=";
        };
        "plugins/voicechat.jar" = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/VloDgjv1/voicechat-bukkit-2.6.4.jar";
          hash = "sha256-Fnq+/orWWHHJV7EpkV+euhpLuHVWjAnu9Vtot2aAjBE=";
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
