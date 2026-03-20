{
  ezModules,
  pkgs,
  ...
}: {
  imports = [
    ezModules.zsh
    ./hardware.nix
  ];

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      dbus
    ];
  };

  wsl.enable = true;
  wsl.defaultUser = "matt";

  networking.hostName = "nomad";
  # services.automatic-timezoned.enable = true;
  system.stateVersion = "24.11";
}
