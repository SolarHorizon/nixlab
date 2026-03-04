{
  inputs,
  lib,
  ...
}: {
  flake.modules.nixos.deployment = {config, ...}: {
    users.users.deploy = {
      isSystemUser = true;
      group = "deploy";
      openssh.authorizedKeys.keys =
        config.users.users.matt.openssh.authorizedKeys.keys;
    };

    users.groups.deploy = {};

    security.sudo.extraRules = [
      {
        users = ["deploy"];
        commands = [
          {
            command = "ALL";
            options = ["NOPASSWD"];
          }
        ];
      }
    ];
  };

  flake.deploy.nodes =
    lib.mapAttrs (host: config: let
      system = config.pkgs.stdenv.hostPlatform.system;

      deployPkgs = import inputs.nixpkgs {
        inherit system;

        overlays = [
          inputs.deploy-rs.overlays.default
          (_: super: {
            deploy-rs = {
              inherit (inputs.nixpkgs.legacyPackages.${system}) deploy-rs;
              lib = super.deploy-rs.lib;
            };
          })
        ];
      };
    in {
      hostname = host;
      sshUser = "deploy";

      profiles.system = {
        user = "root";
        path = deployPkgs.deploy-rs.lib.activate.nixos config;
      };
    })
    inputs.self.nixosConfigurations;

  flake.checks =
    builtins.mapAttrs (
      system: deployLib: deployLib.deployChecks inputs.self.deploy
    )
    inputs.deploy-rs.lib;
}
