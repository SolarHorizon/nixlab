{
  inputs,
  lib,
  self,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options.hosts.nixos = mkOption {
    type = types.lazyAttrsOf (
      types.submodule {
        options.autoUpdate = mkOption {
          default = {};
          type = types.submodule {
            options.enable = mkOption {
              type = types.bool;
              default = false;
            };
            options.strategy = mkOption {
              type = types.nullOr (types.enum ["push" "pull"]);
              default = null;
            };
            options.flake = mkOption {
              type = types.nullOr types.str;
              default = null;
            };
          };
        };
      }
    );
  };

  config.flake.modules.nixos.role-base = {
    imports = with self.modules.nixos; [
      deployment-strategies
    ];
  };

  config.flake.checks =
    builtins.mapAttrs (
      system: deployLib: deployLib.deployChecks self.deploy
    )
    inputs.deploy-rs.lib;
}
