{self, ...}: {
  flake.modules.nixos.role-desktop = {pkgs, ...}: {
    imports = with self.modules.nixos; [
      role-base
      tailscale
      _1password
      _1password-gui
      yubikey-cli
      yubikey-desktop
    ];

    programs.firefox.enable = true;
    programs.kdeconnect.enable = true;
    programs.ssh.startAgent = true;

    networking.networkmanager.enable = true;

    fonts = {
      fontconfig = {
        useEmbeddedBitmaps = true;
      };
      packages = with pkgs; [
        nerd-fonts.fira-code
      ];
    };

    services.printing.enable = true;
    services.flatpak.enable = true;
    services.pulseaudio.enable = false;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    security.rtkit.enable = true;
  };

  flake.modules.homeManager.role-desktop = {pkgs, ...}: {
    imports = with self.modules.homeManager; [
      role-base
    ];

    home.packages = with pkgs; [
      discord
      slack
      spotify
      kdePackages.kdenlive
      thunderbird
      mpv
      jellyfin-mpv-shim
      piper
      moonlight-qt # gaming module
      # alsa-scarlett-gui # desktop-only audio
      # protontricks # gaming module
      # retroarch-full # gaming/emulation module
      # unstable.r2modman # gaming module
    ];
  };
}
