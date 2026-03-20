# not used yet, will try it out later
{self, ...}: {
  flake.factory.site = {
    domain,
    external ? false,
    host,
    name,
    port,
  }: {
    nixos.${host} = {
      imports = [
        self.modules.nixos.${name}
      ];
    };

    nixos."caddy-${
      if external
      then "external"
      else "internal"
    }" = {
      services.caddy.virtualHosts.${domain}.extraConfig = ''
        reverse_proxy ${host}:${toString port} {
        	header_down X-Real-IP {http.request.remote}
        	header_down X-Forwarded-For {http.request.remote}
        }
      '';
    };
  };
}
