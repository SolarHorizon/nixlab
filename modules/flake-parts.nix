{inputs, ...}: {
  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.pkgs-by-name-for-flake-parts.flakeModule
  ];

  systems = [
    "x86_64-linux"
  ];

  perSystem = {pkgs, ...}: {
    formatter = pkgs.alejandra;
  };

  # flake.overlays.default = _final: prev: {
  #   local = withSystem prev.stdenv.hostPlatform.system ({config, ...}: config.packages);
  # };
}
