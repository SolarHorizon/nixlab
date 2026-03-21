{self, ...}: let
  staticIpAddr = "10.0.10.102";
in {
  hosts.nixos.monolith = {
    inherit staticIpAddr;
    autoUpdate.enable = true;
    autoUpdate.strategy = "push";
  };

  flake.modules.nixos.monolith = {
    imports = with self.modules.nixos; [
      role-server
      systemd-boot
      media-server
      caddy-internal
      minecraft
      vintagestory
      valheim-server
    ];

    home-manager.sharedModules = with self.modules.homeManager; [
      role-server
    ];

    networking = {
      interfaces.enp9s0 = {
        ipv4.addresses = [
          {
            address = staticIpAddr;
            prefixLength = 24;
          }
        ];
        useDHCP = false;
      };
      defaultGateway = "10.0.10.1";
    };

    system.stateVersion = "24.05";
  };
}
