{
  flake.modules.nixos.sunshine = {pkgs, ...}: let
    sunshine-udev-rules = pkgs.writeTextFile {
      name = "sunshine-udev-rules";
      text = ''
        # Allows Sunshine to acces /dev/uinput
        KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess"

        # Allows Sunshine to access /dev/uhid
        KERNEL=="uhid", TAG+="uaccess"

        # Joypads
        KERNEL=="hidraw*" ATTRS{name}=="Sunshine PS5 (virtual) pad" MODE="0660", TAG+="uaccess"
        SUBSYSTEMS=="input", ATTRS{name}=="Sunshine Xbox One (virtual) pad", MODE="0660", TAG+="uaccess"
        SUBSYSTEMS=="input", ATTRS{name}=="Sunshine gamepad (virtual) motion sensors", MODE="0660", TAG+="uaccess"
        SUBSYSTEMS=="input", ATTRS{name}=="Sunshine Nintendo (virtual) pad", MODE="0660", TAG+="uaccess"
      '';
      destination = "/etc/udev/rules.d/60-sunshine.rules";
    };

    # Launch steam games from sunshine. Bypasses Sunshine's security wrapper which
    #	prevents Steam from launching.
    steam-run-url = pkgs.writeShellApplication {
      name = "steam-run-url";
      text = ''
        echo "$1" > "/run/user/$(id --user)/steam-run-url.fifo"
      '';
      runtimeInputs = [
        pkgs.coreutils
      ];
    };
  in {
    boot.kernelParams = ["video=HDMI-A-2:1920x1080R@144D"];
    boot.kernelModules = ["uhid"];

    hardware.steam-hardware.enable = true;
    services.udev.packages = [sunshine-udev-rules];

    services.sunshine = let
      kscreen-doctor = "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor";
    in {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
      settings = {
        capture = "kms";
        encoder = "vaapi";
        global_prep_cmd = builtins.toJSON [
          {
            do = "${kscreen-doctor} output.HDMI-A-2.mode.1920x1080@144 output.HDMI-A-2.hdr.disable output.HDMI-A-2.enable output.DP-1.disable output.DP-2.disable";
            undo = "${kscreen-doctor} output.DP-1.enable output.DP-2.enable output.HDMI-A-2.disable output.DP-1.primary";
          }
        ];
      };
      # applications = {
      #   env = {
      #     PATH = "$(PATH):$(HOME)/.local/bin";
      #   };
      #   apps = [
      #     {
      #       name = "Desktop";
      #       image-path = "desktop.png";
      #     }
      #     {
      #       name = "Steam Big Picture";
      #       detached = [
      #         "setsid ${steam-run-url} steam://open/bigpicture"
      #       ];
      #       prep-cmd = [
      #         {
      #           do = "";
      #           undo = "setsid ${steam-run-url} steam://close/bigpicture";
      #         }
      #       ];
      #       image-path = "steam.png";
      #     }
      #   ];
      # };
    };

    systemd.user.services.sunshine.path = [
      steam-run-url
    ];

    systemd.user.services.steam-run-url-service = {
      enable = true;
      wantedBy = ["graphical-session.target"];
      partOf = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig.Restart = "on-failure";
      script = toString (pkgs.writers.writePython3 "steam-run-url-service" {} ''
        import os
        from pathlib import Path
        import subprocess

        pipe_path = Path(f'/run/user/{os.getuid()}/steam-run-url.fifo')
        try:
        		pipe_path.parent.mkdir(parents=True, exist_ok=True)
        		pipe_path.unlink(missing_ok=True)
        		os.mkfifo(pipe_path, 0o600)
        		while True:
        				with pipe_path.open(encoding='utf-8') as pipe:
        						subprocess.Popen(['steam', pipe.read().strip()])
        finally:
        		pipe_path.unlink(missing_ok=True)
      '');
      path = [
        pkgs.steam
      ];
    };

    networking.firewall = {
      allowedTCPPorts = [
        47984
        47989
        48010
      ];
      allowedUDPPorts = [
        47998
        47999
        48000
        48002
        48010
      ];
    };
  };
}
