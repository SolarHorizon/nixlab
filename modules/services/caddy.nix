{self, ...}: {
  flake.modules.nixos.caddy-base = {
    config,
    pkgs,
    ...
  }: {
    services.caddy = {
      enable = true;

      package = pkgs.caddy.withPlugins {
        plugins = ["github.com/caddy-dns/cloudflare@v0.2.2"];
        hash = "sha256-Gb1nC5fZfj7IodQmKmEPGygIHNYhKWV1L0JJiqnVtbs=";
      };

      globalConfig = ''
        cert_issuer acme {
        	dns cloudflare {$CLOUDFLARE_API_TOKEN}
        	resolvers 1.1.1.1 1.0.0.1
        }
      '';
    };

    sops.secrets."caddy/cloudflare_token" = {
      sopsFile = ../../secrets/services/caddy.yaml;
    };

    sops.templates."caddy.env".content = ''
      CLOUDFLARE_API_TOKEN=${config.sops.placeholder."caddy/cloudflare_token"}
    '';

    systemd.services.caddy.serviceConfig.EnvironmentFile = [
      config.sops.templates."caddy.env".path
    ];

    networking.firewall.allowedTCPPorts = [80 443];
  };

  flake.modules.nixos.caddy-external = {
    imports = with self.modules.nixos; [
      caddy-base
    ];
  };

  flake.modules.nixos.caddy-internal = {
    imports = with self.modules.nixos; [
      adguardhome
      caddy-external
    ];
  };
}
