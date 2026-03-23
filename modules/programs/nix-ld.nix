{
  flake.modules.nixos.nix-ld = {pkgs, ...}: {
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        gcc
        openssl
        dbus
      ];
    };
  };
}
