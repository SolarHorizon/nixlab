# TODO: figure out a way to handle this for projects that need it instead of globally
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
