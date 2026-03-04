{self, ...}: {
  flake.modules.nixos.profile-desktop = {pkgs, ...}: {
    imports = with self.modules.nixos; [
      profile-cli
      _1password-gui
      yubikey-gui
    ];

    programs.firefox.enable = true;
    programs.kdeconnect.enable = true;

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

    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  flake.modules.homeManager.profile-desktop = {pkgs, ...}: {
    imports = with self.modules.homeManager; [
      profile-cli
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
      moonlight-qt
      # alsa-scarlett-gui # desktop-only audio
      # local.nix-modrinth-prefetch # gaming module
      # looking-glass-client # looking-glass module
      # protontricks # gaming module
      # retroarch-full # gaming/emulation module
      # unstable.mcaselector # gaming module
      # unstable.packwiz # gaming module
      # unstable.r2modman # gaming module
    ];
  };
}
