{self, ...}: let
  host = "monolith";
  domain = "radarr.matthewlabs.net";
  port = 7878;
in {
  flake.modules.nixos.radarr = {
    pkgs,
    config,
    ...
  }: {
    services.radarr = {
      enable = true;
      package = pkgs.unstable.radarr;
      openFirewall = true;
      group = config.media-server.group;
    };
  };

  flake.modules.nixos.recyclarr = {config, ...}: {
    sops.secrets."radarr/api_key" = {
      sopsFile = ../../../secrets/services/radarr.yaml;
      group = config.media-server.group;
      mode = "0440";
    };

    services.recyclarr.configuration.radarr.radarr_main = {
      url = "https://${domain}";
      api_key = {
        _secret = config.sops.secrets."radarr/api_key".path;
      };
    };
  };

  flake.modules.nixos.caddy-internal = self.lib.mkReverseProxy {
    inherit domain host port;
  };

  flake.modules.nixos.${host} = {
    imports = with self.modules.nixos; [
      radarr
    ];
  };
}
