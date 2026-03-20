{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.nixlab.beacn;

  systemdPkg = config.systemd.package or pkgs.systemd;

  needsBeacnRules = lib.versionOlder systemdPkg.version "257.7";

  udevRules = pkgs.writeTextFile {
    name = "beacn-udev-rules";
    text = ''
      # Beacn Mic
      SUBSYSTEM=="usb", ATTR{idVendor}=="33ae", ATTR{idProduct}=="0001", TAG+="uaccess"

      # Beacn Studio
      SUBSYSTEM=="usb", ATTR{idVendor}=="33ae", ATTR{idProduct}=="0003", TAG+="uaccess"

      # Beacn Mix
      SUBSYSTEM=="usb", ATTR{idVendor}=="33ae", ATTR{idProduct}=="0004", TAG+="uaccess"

      # Beacn Mix Create
      SUBSYSTEM=="usb", ATTR{idVendor}=="33ae", ATTR{idProduct}=="0007", TAG+="uaccess"
    '';
    destination = "/etc/udev/rules.d/50-beacn.rules";
  };

  upstreamUcm = config.alsa-ucm-conf.version or pkgs.alsa-ucm-conf;

  needsPinnedUcm = lib.versionOlder upstreamUcm.version "1.2.15";

  pinnedUcm = pkgs.stdenvNoCC.mkDerivation {
    pname = "beacn-ucm-conf";
    version = "git-1.2.15-pre-1b69ad";
    src = pkgs.fetchFromGitHub {
      owner = "alsa-project";
      repo = "alsa-ucm-conf";
      rev = "1b69ade9b6d7ee37a87c08b12d7955d0b68fa69d";
      hash = "sha256-7PxI1/vQhrYOneNNRQI1vflPLqfd/ug1MorsZSQ5B3U=";
    };

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      mkdir -p $out/share/alsa/ucm2
      cp -R ucm2/* $out/share/alsa/ucm2/
    '';
  };

  defaultUcm =
    if needsPinnedUcm
    then pinnedUcm
    else upstreamUcm;

  beacnUcmChosen =
    if cfg.ucmConf.forcePinned
    then pinnedUcm
    else cfg.ucmConf.package;
in {
  options.nixlab.beacn = {
    enable = lib.mkEnableOption "Enable BEACN integration";

    pipeweaver = {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.local.pipeweaver-daemon;
        description = "Package used by the pipeweaver service";
      };
    };

    beacn-utility.package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.local.beacn-utility;
      description = "beacn-utility package to install";
    };

    ucmConf.package = lib.mkOption {
      type = lib.types.package;
      default = defaultUcm;
      description = ''
        ALSA UCM package to use for BEACN devices.
        Defaults to a pinned alsa-ucm-conf if upstream < 1.2.15.
      '';
    };

    ucmConf.forcePinned = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Force using the pinned alsa-ucm-conf regardless of the upstream version.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.udev.packages = lib.mkIf needsBeacnRules [udevRules];

    environment.sessionVariables.ALSA_CONFIG_UCM2 = "${beacnUcmChosen}/share/alsa/ucm2";

    environment.systemPackages = [
      cfg.beacn-utility.package
      cfg.pipeweaver.package
      pkgs.local.pipeweaver-app
    ];

    systemd.user.services.pipeweaver = let
      package = cfg.pipeweaver.package;
    in {
      enable = true;
      reloadIfChanged = true;
      description = "Pipeweaver Daemon";
      after = [
        "network.target"
        "graphical-session.target"
        "pipewire.service"
      ];
      wants = [
        "graphical-session.target"
        "pipewire.service"
      ];
      partOf = [
        "graphical-session.target"
      ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.stdenv.shell} -lc '${package}/bin/pipeweaver-daemon'";
        Environment = "PATH=${pkgs.xdg-utils}/bin:/run/current-system/sw/bin:/bin:/usr/bin";
      };
      wantedBy = ["graphical-session.target"];
    };

    system.activationScripts.beacn-ucm-check = lib.stringAfter ["etc"] ''
      set -u

      BEACN_DIR="${beacnUcmChosen}/share/alsa/ucm2/USB-Audio/Beacn"

      if [ ! -d "$BEACN_DIR" ]; then
        echo "warning: BEACN: Expected UCM directory not found: $BEACN_DIR" >&2
      else
        if ! ls -A "$BEACN_DIR" >/dev/null 2>&1; then
          echo "warning: BEACN: Unable to read $BEACN_DIR" >&2
        elif [ -z "$(ls -A "$BEACN_DIR")" ]; then
          echo "warning: BEACN: UCM directory exists but is empty: $BEACN_DIR" >&2
        fi
      fi
    '';
  };
}
