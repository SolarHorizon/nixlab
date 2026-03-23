{
  flake.modules.nixos.beacn = {
    config,
    pkgs,
    lib,
    ...
  }: let
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

    ucmConf =
      if needsPinnedUcm
      then pinnedUcm
      else upstreamUcm;
  in {
    services.udev.packages = lib.mkIf needsBeacnRules [udevRules];

    environment.sessionVariables.ALSA_CONFIG_UCM2 = "${ucmConf}/share/alsa/ucm2";

    environment.systemPackages = [
      pkgs.local.beacn-utility-unstable
      pkgs.local.pipeweaver-daemon
      pkgs.local.pipeweaver-app
    ];

    systemd.user.services.pipeweaver = let
      package = pkgs.local.pipeweaver-daemon;
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

      BEACN_DIR="${ucmConf}/share/alsa/ucm2/USB-Audio/Beacn"

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
