{
  flake.modules.nixos.adguardhome = {
    services.adguardhome = {
      enable = true;
      openFirewall = true;
      settings = {
        dns.rewrites = [
          {
            domain = "matthewlabs.net";
            answer = "127.0.0.1";
          }
          {
            domain = "*.matthewlabs.net";
            answer = "A";
          }
        ];
      };
    };
  };
}
