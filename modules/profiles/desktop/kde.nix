{self, ...}: {
  flake.modules.nixos.profile-kde = {pkgs, ...}: {
    imports = with self.modules.nixos; [
      profile-desktop
    ];

    environment.systemPackages = with pkgs; [
      (writeShellScriptBin "restart" ''
        qdbus org.kde.Shutdown /Shutdown logoutAndReboot
      '')
      # only relevant for desktop
      # (
      #   writeShellScriptBin "win-reboot" ''
      #     sudo efibootmgr --bootnext 0000 \
      #       && qdbus org.kde.Shutdown /Shutdown logoutAndReboot
      #   ''
      # )
    ];

    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;
    services.xserver.enable = true;
  };

  flake.modules.homeManager.profile-kde = {
    imports = with self.modules.homeManager; [
      profile-desktop
    ];
  };
}
