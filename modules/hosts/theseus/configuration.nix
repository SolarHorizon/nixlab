{self, ...}: {
  hosts.nixos.theseus = {
    # autoUpdate.enable = true;
    # autoUpdate.strategy = "pull";
  };

  flake.modules.nixos.theseus = {pkgs, ...}: {
    imports = with self.modules.nixos; [
      role-kde
      lanzaboote
      windows-vm
      beacn
      nix-ld
      sunshine
    ];

    home-manager.sharedModules = with self.modules.homeManager; [
      role-kde
    ];

    system.stateVersion = "25.05";

    ### need to find a home for everything below

    environment.systemPackages = with pkgs; [
      alsa-utils # using this to mute/unmute beacn mic with a kde hotkey
      gparted # useful sometimes
      keymapp # for moonlander config
      pciutils # used when debugging vm gpu issues
      vulkan-tools # ditto
      unrar # not sure if ive used this, usually extract thru kde's file manager
      ladspaH # dont remember why i have this
      ladspaPlugins # ditto
      efibootmgr # need this for the following script
      # reboot into windows (dual boot)
      (
        writeShellScriptBin "win-reboot" ''
          sudo efibootmgr --bootnext 0000 \
            && qdbus org.kde.Shutdown /Shutdown logoutAndReboot
        ''
      )
    ];

    # oss mouse config (replaces shitty windows-only gamer peripheral software)
    services.ratbagd.enable = true;

    # xbox controller support
    # broken on 25.11
    # hardware.xone.enable = true;

    # moonlander keyboard
    # not sure what this actually does, keyboard seems to work fine without it
    hardware.keyboard.zsa.enable = true;

    # can't remember why i had to enable this
    hardware.graphics.enable32Bit = true;

    # gaming
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    # for games distributed as AppImages
    programs.appimage.enable = true;
    programs.appimage.binfmt = true;

    # Enable flatpak support
    # i only need this for sober
    services.flatpak.enable = true;

    # config for chrome-based browsers
    # i want to have both chromium and firefox on my desktop pc
    programs.chromium = {
      enable = true;
      extensions = [
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
        "pkehgijcmpdhfbdbbnkijodmdjhbjlgp" # privacy badger
        "dbepggeogbaibhgnhhndojpepiihcmeb" # vimium
      ];
    };
  };
}
