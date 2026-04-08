{self, ...}: {
  flake.modules.nixos.renovate = {
    config,
    pkgs,
    ...
  }: {
    sops.secrets."renovate/forgejo-token" = {
      sopsFile = ../../../secrets/services/renovate.yaml;
    };

    sops.secrets."renovate/github-token" = {
      sopsFile = ../../../secrets/services/renovate.yaml;
    };

    services.renovate = {
      enable = true;
      schedule = "*:0/30";
      credentials = {
        RENOVATE_TOKEN = config.sops.secrets."renovate/forgejo-token".path;
        GITHUB_COM_TOKEN = config.sops.secrets."renovate/github-token".path;
      };
      environment = {
        LOG_LEVEL = "debug";
      };
      runtimePackages = [pkgs.nix];
      settings = {
        platform = "forgejo";
        endpoint = "https://git.matt.you/api/v1";
        gitAuthor = "renovate<renovate@noreply>";
        autodiscover = true;
        autodiscoverTopics = ["renovate"];
      };
    };
  };

  flake.modules.nixos.monolith = {
    imports = with self.modules.nixos; [
      renovate
    ];
  };
}
