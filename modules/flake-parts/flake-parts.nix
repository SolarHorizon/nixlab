{
  inputs,
  withSystem,
  ...
}: {
  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.pkgs-by-name-for-flake-parts.flakeModule
  ];

  systems = [
    "x86_64-linux"
  ];

  perSystem = {pkgs, ...}: {
    formatter = pkgs.alejandra;
    pkgsDirectory = ../../packages;
  };

  flake.overlays.default = _final: prev:
    withSystem prev.stdenv.hostPlatform.system ({
      config,
      system,
      ...
    }: {
      local = config.packages;
      unstable = import inputs.nixpkgs-unstable {inherit system;};
    });
}
