{
  inputs,
  self,
  config,
  lib,
  ...
}: {
  flake.deploy.nodes =
    config.hosts.nixos
    |> lib.filterAttrs (_: cfg: cfg.autoUpdate.enable && cfg.autoUpdate.strategy == "push")
    |> lib.mapAttrs (hostname: _: let
      nixosCfg = self.nixosConfigurations.${hostname};
      system = nixosCfg.pkgs.stdenv.hostPlatform.system;

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
      inherit hostname;

      sshUser = "deploy";
      sshOpts = ["-i" "~/.ssh/deploy_key"];

      profiles.system = {
        user = "root";
        path = deployPkgs.deploy-rs.lib.activate.nixos nixosCfg;
      };
    });
}
