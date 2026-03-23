{self, ...}: {
  flake.modules.nixos.role-kde = {pkgs, ...}: {
    imports = with self.modules.nixos; [
      role-desktop
    ];

    environment.systemPackages = with pkgs; [
      (writeShellScriptBin "restart" ''
        qdbus org.kde.Shutdown /Shutdown logoutAndReboot
      '')
    ];

    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;
    services.xserver.enable = true;
  };

  flake.modules.homeManager.role-kde = {
    imports = with self.modules.homeManager; [
      role-desktop
    ];
  };
}
