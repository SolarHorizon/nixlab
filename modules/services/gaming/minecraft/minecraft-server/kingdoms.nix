{inputs, ...}: {
  flake.modules.nixos.minecraft-kingdoms = {
    lib,
    pkgs,
    ...
  }: let
    inherit (inputs.nix-minecraft.lib) collectFilesAt;

    modpack = pkgs.fetchPackwizModpack {
      url = "https://raw.githubusercontent.com/SolarHorizon/kingdoms/tags/4.2.2/pack.toml";
      packHash = "sha256-WNlFZFxXbjoq5Jc6VH8TXRYsxl6VYSs1sI1kmCJOLzE=";
      side = "server";
    };

    version = "${modpack.manifest.versions.minecraft}-${modpack.manifest.versions.forge}";

    installer = pkgs.fetchurl {
      pname = "forge-installer";
      url = "https://maven.minecraftforge.net/net/minecraftforge/forge/${version}/forge-${version}-installer.jar";
      hash = "sha256-8/V0ZeLL3DKBk/d7p/DJTLZEBfMe1VZ1PZJ16L3Abiw=";
    };

    server = pkgs.writeShellScriptBin "server" ''
      if ! [ -e "forge-${version}.jar" ]; then
      	${pkgs.graalvm-ce}/bin/java -jar ${installer} --installServer
      fi
      exec ${pkgs.graalvm-ce}/bin/java $@ @libraries/net/minecraftforge/forge/1.20.1-47.4.0/unix_args.txt -jar forge-${version}.jar nogui
    '';
  in {
    services.minecraft-servers.servers.kingdoms = {
      enable = true;
      package = server;

      symlinks =
        collectFilesAt modpack "mods"
        // {
          "mods/chunky-player-pause.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/wYO04fON/versions/4QMoZ8ZF/chunky-player-pause-1.0.0.jar";
            hash = "sha256-RWEfOJQ4tZ65UH44cd3sL01PlqvOr5HCqSPqgeDDTug=";
          };
          "mods/proxy-compatible-forge.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/vDyrHl8l/versions/jfiEc2mQ/proxy-compatible-forge-1.1.7.jar";
            hash = "sha256-Ep7/jd5FddKpLMVrVkjy5TTcms9dLhf3qvu5UapmDdo=";
          };
          "mods/no-chat-reports.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/qQyHxfxd/versions/ksEG6N5E/NoChatReports-FORGE-1.20.1-v2.2.2.jar";
            hash = "sha256-73+lCW39SSw9OuciiIjKS5LOB9m44wIpfOss6x+NI4w=";
          };
          "mods/canary.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/qa2H4BS9/versions/lauzXB0n/canary-mc1.20.1-0.3.3.jar";
            hash = "sha256-UfbXjdbHh0ZX5XV/0vXXgKo81BUFKtBxB3uIlMZDCUI=";
          };
          "mods/ai-improvements" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/DSVgwcji/versions/eJihmpNQ/AI-Improvements-1.20-0.5.2.jar";
            hash = "sha256-V1pKjgD5gsBk1Uuz5z5c2i0UQU3gVKRxo9rz9YvfVgo=";
          };
          "mods/spark.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/l6YH9Als/versions/4FXHDE9F/spark-1.10.53-forge.jar";
            hash = "sha256-66J1upuwy1tUKRPDE4xu7/anUomCZtY9El0YXyasme0=";
          };
        };
      files =
        collectFilesAt modpack "config"
        // {
          "allowed_symlinks.txt".value = ["/nix/store"];

          "config/pcf-common.toml".value = {
            modernForwarding.forwardingSecret = "@forwardingSecret@";
            commandWrapping.moddedArgumentTypes = ["livingthings:sampler_types"];
          };

          "config/sparsestructures.json5" = {
            format = pkgs.formats.json {};
            value = {
              spreadFactor = 1.5;
              idBasedSalt = true;
              customSpreadFactors = [
                {
                  structure = "minecraft:end_city";
                  factor = 1;
                }
              ];
            };
          };
        };

      jvmOpts = lib.concatStringsSep " " [
        "-Xmx20G"
        "-Xms8G"
        "-XX:+UnlockExperimentalVMOptions"
        "-XX:+UnlockDiagnosticVMOptions"
        "-XX:+AlwaysPreTouch"
        "-XX:+DisableExplicitGC"
        "-XX:+UseG1GC"
        "-XX:MaxGCPauseMillis=130"
        "-XX:+ParallelRefProcEnabled"
        "-XX:ReservedCodeCacheSize=400M"
        "-XX:NonNMethodCodeHeapSize=12M"
        "-XX:ProfiledCodeHeapSize=194M"
        "-XX:NonProfiledCodeHeapSize=194M"
        "-XX:+UseFastUnorderedTimeStamps"
        "-XX:+EagerJVMCI"
        "-XX:G1NewSizePercent=28"
        "-XX:G1HeapRegionSize=16M"
        "-XX:G1ReservePercent=20"
        "-XX:InitiatingHeapOccupancyPercent=10"
        "-XX:SurvivorRatio=32"
        "-XX:MaxTenuringThreshold=1"
        "-XX:AllocatePrefetchStyle=3"
      ];
    };

    networking.firewall.allowedUDPPorts = [24454];
  };
}
