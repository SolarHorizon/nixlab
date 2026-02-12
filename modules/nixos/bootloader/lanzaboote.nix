{
  lib,
  inputs,
  ...
}: {
  flake.modules.nixos.lanzaboote = {pkgs, ...}: {
    imports = [
      inputs.lanzaboote.nixosModules.lanzaboote
    ];

    environment.systemPackages = with pkgs; [
      sbctl
    ];

    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    boot.loader.systemd-boot.enable = lib.mkForce false;
  };
}
