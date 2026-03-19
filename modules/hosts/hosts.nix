{
  lib,
  self,
  config,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options.hosts.nixos = mkOption {
    type = types.lazyAttrsOf (
      types.submodule ({name, ...}: {
        options.name = mkOption {
          type = types.str;
          default = name;
        };
        options.module = mkOption {
          type = types.deferredModule;
          default = self.modules.nixos.${name};
        };
        options.staticIpAddr = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
      })
    );
  };

  config.flake = {
    nixosConfigurations = lib.flip lib.mapAttrs config.hosts.nixos (
      name: {module, ...}:
        lib.nixosSystem {
          modules = [
            module
            {
              _module.args = {
                hostConfig = config.hosts.nixos.${name};
                nixlab.hosts = config.hosts;
              };

              networking.hostName = name;
            }
          ];
        }
    );

    checks =
      config.flake.nixosConfigurations
      |> lib.mapAttrsToList (
        name: nixos: {
          ${nixos.config.nixpkgs.hostPlatform.system} = {
            "hosts/nixos/${name}" = nixos.config.system.build.toplevel;
          };
        }
      )
      |> lib.mkMerge;
  };
}
