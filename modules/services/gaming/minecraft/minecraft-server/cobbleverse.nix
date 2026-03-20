{inputs, ...}: {
  flake.modules.nixos.minecraft-cobbleverse = {
    lib,
    pkgs,
    ...
  }: let
    inherit (inputs.nix-minecraft.lib) collectFilesAt;

    mrpackFile = pkgs.fetchurl {
      url = "https://cdn.modrinth.com/data/Jkb29YJU/versions/jImAfjVc/COBBLEVERSE%201.7.30.mrpack";
      hash = "sha256-/1ouoVSzoYMxf9ITrcdep4UTnLh0ODr9T+A5CQPzLec=";
    };

    mrpack =
      pkgs.runCommand "cobbleverse-modpack" {
        nativeBuildInputs = [pkgs.unzip];
      } ''
        unzip ${mrpackFile} -d $out
        chmod -R +r $out
      '';

    modrinthIndex = builtins.fromJSON (builtins.readFile "${mrpack}/modrinth.index.json");

    # Download all files from the index and assemble them into a derivation
    # Filter out client-only files (none in this modpack, but good practice)
    indexFiles =
      builtins.filter (
        file: !(file ? env) || file.env.server != "unsupported"
      )
      modrinthIndex.files;

    # Build individual derivations for each file at its correct path
    fileDerivations =
      map (
        file: let
          pathParts = builtins.match "(.*)/(.*)" file.path;
          folder = builtins.head pathParts;
          name = builtins.elemAt pathParts 1;
        in
          pkgs.runCommand name {} ''
            mkdir -p "$out/${folder}"
            cp ${pkgs.fetchurl {
              urls = file.downloads;
              inherit (file.hashes) sha512;
            }} "$out/${file.path}"
          ''
      )
      indexFiles;

    # Merge all downloaded files with the overrides from the mrpack
    modpack = pkgs.symlinkJoin {
      name = "cobbleverse-${modrinthIndex.versionId}";
      paths = fileDerivations ++ ["${mrpack}/overrides"];
    };
  in {
    services.minecraft-servers.servers.cobbleverse = {
      enable = true;

      package = pkgs.fabricServers.fabric-1_21_1.override {
        loaderVersion = "0.18.4";
      };

      serverProperties = {
        allow-flight = true;
        enable-command-blocks = true;
      };

      # Symlink immutable content — mods and resource packs don't need to be writable
      # Resource packs are included because globalpacks mod serves them to clients
      symlinks =
        collectFilesAt modpack "mods"
        // collectFilesAt modpack "resourcepacks";

      # Copy mutable content — config files must be writable (mods write to them at runtime)
      # datapacks go through globalpacks mod from root datapacks/
      files =
        collectFilesAt modpack "config"
        // collectFilesAt modpack "datapacks";

      jvmOpts = lib.concatStringsSep " " [
        "-Xmx16G"
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
  };
}
