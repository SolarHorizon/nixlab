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

  flake.modules.nixos.caddy-internal = {config, ...}: {
    imports = with self.modules.nixos; [
      caddy-external
    ];

    # services.adguardhome = {
    #   enable = true;
    #   openFirewall = true;
    #   settings.dns.rewrites = map (domain: {
    #     inherit domain;
    #     answer = "127.0.0.1";
    #   }) (builtins.attrNames config.services.caddy.virtualHosts);
    # };

    services.dnsmasq = {
      enable = true;
      settings = {
        server = ["1.1.1.1" "1.0.0.1"];
        address =
          map (domain: "/${domain}/127.0.0.1")
          (builtins.attrNames config.services.caddy.virtualHosts);
      };
    };

    networking.firewall = {
      allowedTCPPorts = [53];
      allowedUDPPorts = [53];
    };
  };
}
