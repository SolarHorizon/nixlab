{self, ...}: let
  host = "monolith";
  domain = "cache.matt.you";
  port = 8090;
in {
  flake.modules.nixos.attic = {config, ...}: {
    services.atticd = {
      enable = true;
      settings = {
        listen = "[::]:${toString port}";
        api-endpoint = "https://${domain}/";
      };
      environmentFile = config.sops.templates."attic.env".path;
    };

    sops.secrets."attic/token" = {
      sopsFile = ../../secrets/services/attic.yaml;
    };

    sops.templates."attic.env".content = ''
      ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64=${config.sops.placeholder."attic/token"}
    '';
  };

  flake.modules.nixos.caddy-internal = self.lib.mkReverseProxy {
    inherit domain host port;
  };

  flake.modules.nixos.${host} = {
    imports = with self.modules.nixos; [
      attic
    ];
  };
}
