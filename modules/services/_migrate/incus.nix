let
  incusInterface = "incusbr0";
  ethernetInterface = "enp9s0";
in {
  users.users.matt.extraGroups = [
    "incus-admin"
  ];

  networking = {
    networkmanager.enable = false;
    useNetworkd = true;
    nftables.enable = true;
    bridges.br0 = {
      interfaces = [ethernetInterface];
    };
    interfaces.br0 = {
      useDHCP = true;
    };
    firewall.trustedInterfaces = [ethernetInterface];
  };

  virtualisation.incus = {
    enable = true;
    ui.enable = true;
    preseed = {
      networks = [
        {
          name = incusInterface;
          type = "bridge";
          config = {
            "ipv4.address" = "10.0.100.1/24";
            "ipv4.nat" = "true";
          };
        }
      ];
      storage_pools = [
        {
          name = "default";
          driver = "dir";
          config = {
            source = "/var/lib/incus/storage-pools/default";
          };
        }
      ];
      profiles = [
        {
          name = "default";
          devices = {
            eth0 = {
              name = "eth0";
              network = incusInterface;
              type = "nic";
            };
            root = {
              path = "/";
              pool = "default";
              type = "disk";
            };
          };
        }
      ];
    };
  };
}
