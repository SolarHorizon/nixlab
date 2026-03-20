{self, ...}: let
  host = "monolith";
  domain = "search.matthewlabs.net";
  port = 8888;
in {
  flake.modules.nixos.searxng = {config, ...}: {
    sops.secrets."searxng/secret_key" = {
      sopsFile = ../../secrets/services/searxng.yaml;
    };

    sops.templates."searxng.env".content = ''
      SEARXNG_SECRET=${config.sops.placeholder."searxng/secret_key"}
    '';

    services.searx = {
      enable = true;
      redisCreateLocally = true;
      environmentFile = config.sops.templates."searxng.env".path;

      settings = {
        server = {
          base_url = "https://${domain}";
          bind_address = "127.0.0.1";
          port = port;
          public_instance = false;
        };
        search = {
          autocomplete = "google";
          favicon_resolver = "google";
        };
        ui = {
          query_in_title = true;
          infinite_scroll = true;
          center_alignment = true;
        };
      };
    };
  };

  flake.modules.nixos.caddy-external = self.lib.mkReverseProxy {
    inherit domain host port;
  };

  flake.modules.nixos.${host} = {
    imports = with self.modules.nixos; [
      searxng
    ];
  };
}
