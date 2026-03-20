# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  # ezModules,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./sunshine.nix
    # ezModules.zsh
    # ezModules.beacn
    # ezModules.virtualization
    # ezModules.looking-glass
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.plymouth.enable = true;
  # boot.initrd.systemd.enable = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable networking
  networking.hostName = "theseus";
  networking.networkmanager.enable = true;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain"

  # moonlander
  hardware.keyboard.zsa.enable = true;

  # xbox controller support
  # broken on 25.11
  # hardware.xone.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # tailscale
  services.tailscale.enable = true;

  # enable automatic firmware updates
  services.fwupd.enable = true;

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable flatpak support
  services.flatpak.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # Ratbagd
  services.ratbagd.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.matt = {
    isNormalUser = true;
    description = "matt";
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
      # "libvirtd"
      # "kvm"
    ];
    packages = with pkgs;
      [
        discord
        slack
        spotify
        thunderbird
        looking-glass-client
        kdePackages.kdenlive
        unstable.r2modman
        unstable.packwiz
        mpv
        jellyfin-mpv-shim
        unstable.browsers
        protontricks
        alsa-scarlett-gui
        unstable.mcaselector
        piper
        local.nix-modrinth-prefetch
        retroarch-full
      ]
      ++ [
        (
          writeShellScriptBin "win-reboot" ''
            sudo efibootmgr --bootnext 0000 \
              && qdbus org.kde.Shutdown /Shutdown logoutAndReboot
          ''
        )
        (
          writeShellScriptBin "restart" ''
            qdbus org.kde.Shutdown /Shutdown logoutAndReboot
          ''
        )
      ];
  };

  programs.kdeconnect.enable = true;

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = ["matt"];
  };

  fonts = {
    packages = with pkgs; [
      nerd-fonts.fira-code
    ];
    fontconfig = {
      useEmbeddedBitmaps = true;
    };
  };

  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  # for games distributed as AppImages
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  # Install firefox.
  programs.firefox.enable = true;

  # Chrome-based browsers
  programs.chromium = {
    enable = true;
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
      "pkehgijcmpdhfbdbbnkijodmdjhbjlgp" # privacy badger
      "dbepggeogbaibhgnhhndojpepiihcmeb" # vimium
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    alsa-utils
    git
    gparted
    keymapp
    pciutils
    vulkan-tools
    # lutris
    ladspaH
    ladspaPlugins
    chromium
    unrar
    efibootmgr
    compose2nix
    kdePackages.qtwebsockets
  ];

  hardware.graphics.enable32Bit = true;

  nixlab = {
    beacn = {
      enable = true;
      beacn-utility.package = pkgs.local.beacn-utility-unstable;
    };
    libreoffice.enable = true;
    roblox-dev.enable = true;
    virtualization = {
      enable = true;
      looking-glass.enable = true;
      samba.enable = true;
      # virtiofs.enable = true;
    };
    secureboot.enable = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # networking.firewall.allowedUDPPorts = [34872];
  # networking.firewall.allowedTCPPorts = [34872];

  networking.firewall.enable = true;
  networking.interfaces.enp14s0.wakeOnLan.enable = true;
  networking.firewall.allowedTCPPorts = [34872];
  networking.firewall.allowedUDPPorts = [34872];
  networking.firewall.allowedTCPPortRanges = [
    {
      from = 50000;
      to = 65535;
    }
  ];
  networking.firewall.allowedUDPPortRanges = [
    {
      from = 50000;
      to = 65535;
    }
  ];

  networking.extraHosts = ''
    192.168.122.98 shadow
  '';

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
