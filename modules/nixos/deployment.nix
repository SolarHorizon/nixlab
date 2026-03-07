{
  inputs,
  lib,
  ...
}: {
  flake.modules.homeManager.deployment-auth = {
    config,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [
      deploy-rs
    ];

    sops.secrets."ssh/deploy_key" = {
      path = "${config.home.homeDirectory}/.ssh/deploy_key";
      mode = "0600";
    };
  };

  flake.modules.nixos.deployment = {pkgs, ...}: {
    users.users.deploy = {
      isSystemUser = true;
      group = "deploy";
      shell = pkgs.bash;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH1B4bByBCRr2ZUMOqRoiuCy6NtpWTOfbIq5mKPKPZkx deploy@nixlab"
      ];
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

    nix.settings.trusted-users = ["deploy"];
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
      sshOpts = ["-i" "~/.ssh/deploy_key"];

      profiles.system = {
        user = "root";
        path = deployPkgs.deploy-rs.lib.activate.nixos config;
      };
    })
    (lib.filterAttrs (_: config: config.config.users.users ? deploy)
      inputs.self.nixosConfigurations);

  flake.checks =
    builtins.mapAttrs (
      system: deployLib: deployLib.deployChecks inputs.self.deploy
    )
    inputs.deploy-rs.lib;
}
