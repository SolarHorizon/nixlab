{self, ...}: let
  host = "monolith";
  domain = "sonarr.matthewlabs.net";
  port = 8989;
in {
  flake.modules.nixos.sonarr = {
    pkgs,
    config,
    ...
  }: {
    services.sonarr = {
      enable = true;
      package = pkgs.unstable.sonarr;
      openFirewall = true;
      group = config.media-server.group;
    };
  };

  flake.modules.nixos.recyclarr = {config, ...}: {
    sops.secrets."sonarr/api_key" = {
      sopsFile = ../../../secrets/services/sonarr.yaml;
    };

    services.recyclarr.configuration.sonarr.sonarr_main = {
      url = "https://${domain}";
      api_key = {
        _secret = config.sops.secrets."sonarr/api_key".path;
      };
    };
  };

  flake.modules.nixos.caddy-internal = self.lib.mkReverseProxy {
    inherit domain host port;
  };

  flake.modules.nixos.${host} = {
    imports = with self.modules.nixos; [
      sonarr
    ];
  };
}
