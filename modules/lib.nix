{
  inputs,
  lib,
  ...
}: {
  options.flake.lib = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = {};
  };

  config.flake.lib = {
    mkHomeManager = system: name: {
      ${name} = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        modules = [
          inputs.self.modules.homeManager.${name}
        ];
      };
    };

    mkReverseProxy = {
      domain,
      host,
      port,
    }: {
      services.caddy.virtualHosts.${domain}.extraConfig = ''
        reverse_proxy ${host}:${toString port} {
        	header_down X-Real-IP {http.request.remote}
        	header_down X-Forwarded-For {http.request.remote}
        }
      '';
    };
  };
}
