{
  inputs,
  lib,
  ...
}: let
  getPkgNames = pkg: builtins.elem (lib.getName pkg);
in {
  flake.modules.nixos._1password = {config, ...}: {
    imports = [
      inputs._1password-shell-plugins.nixosModules.default
    ];

    nixpkgs.config.allowUnfreePredicate = getPkgNames [
      config.programs._1password.package
    ];

    programs._1password.enable = true;
    programs._1password-shell-plugins.enable = true;
  };

  flake.modules.nixos._1password-gui = {config, ...}: {
    nixpkgs.config.allowUnfreePredicate = getPkgNames [
      config.programs._1password-gui.package
    ];

    programs._1password-gui.enable = true;
  };
}
