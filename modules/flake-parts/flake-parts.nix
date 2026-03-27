{
  inputs,
  withSystem,
  ...
}: {
  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.pkgs-by-name-for-flake-parts.flakeModule
    inputs.treefmt-nix.flakeModule
  ];

  systems = [
    "x86_64-linux"
  ];

  perSystem = {pkgs, ...}: {
    treefmt = {
      projectRootFile = "flake.nix";
      settings.excludes = [
        "secrets/*"
        ".sops.yaml"
      ];
      programs = {
        alejandra.enable = true;
        prettier.enable = true;
        shfmt.enable = true;
      };
    };
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
