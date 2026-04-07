{
  self,
  lib,
  ...
}: let
  forgejoUrl = "https://git.matt.you/";
  imageName = "ghcr.io/joschi/forgejo-nix";
  imageTag = "latest";
in {
  flake.modules.nixos.nix-ci-runner = {
    config,
    pkgs,
    ...
  }: let
    # TODO: make this dynamic
    dnsServer = "100.121.126.46";

    envShim = pkgs.writeScript "env-shim" ''
      #!/bin/bash
      exec /bin/env "$@"
    '';

    nixConfig = pkgs.writeText "nix-ci.conf" ''
      experimental-features = nix-command flakes pipe-operators
      accept-flake-config = true
      nix-path = nixpkgs=flake:nixpkgs
      max-jobs = auto
      cores = 0
      extra-substituters = https://cache.matt.you/nixlab
      extra-trusted-public-keys = nixlab:vilT3iOpIuRLcVUs2EGxl4njjVNlM5oaundgBhOXj60=
    '';

    runners = ["monolith-1" "monolith-2" "monolith-3"];

    mkRunner = name: {
      services.gitea-actions-runner.instances.${name} = {
        enable = true;
        inherit name;
        tokenFile = config.sops.templates."forgejo-runner.env".path;
        url = forgejoUrl;
        labels = [
          "nix:docker://${imageName}:${imageTag}"
        ];
        settings.container = {
          options = "--dns ${dnsServer} --cpus=24 -v ${nixConfig}:/etc/nix/nix.conf:ro -v ${envShim}:/usr/bin/env:ro";
          valid_volumes = [
            "${nixConfig}"
            "${envShim}"
          ];
        };
      };
    };
  in
    lib.mkMerge (
      (map mkRunner runners)
      ++ [
        {
          sops.secrets."forgejo/runner-token" = {
            sopsFile = ../../../secrets/services/forgejo.yaml;
          };

          sops.templates."forgejo-runner.env".content = ''
            TOKEN=${config.sops.placeholder."forgejo/runner-token"}
          '';

          services.gitea-actions-runner.package = pkgs.forgejo-runner;

          virtualisation.podman = {
            enable = true;
            dockerSocket.enable = true;
          };

          networking.firewall.trustedInterfaces = ["br-+"];
        }
      ]
    );

  flake.modules.nixos.monolith = {
    imports = with self.modules.nixos; [
      nix-ci-runner
    ];
  };
}
