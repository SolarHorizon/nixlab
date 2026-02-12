{inputs, ...}: {
  flake.modules.nixos.home-manager = {
    imports = [
      inputs.home-manager.nixosModules.default
    ];
  };
}
