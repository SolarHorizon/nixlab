{lib, ...}: {
  flake.modules.nixos.networking = {
    networking = {
      networkmanager.enable = true;
      nftables.enable = true;
      firewall.enable = true;
      useDHCP = lib.mkDefault true;
    };
  };
}
