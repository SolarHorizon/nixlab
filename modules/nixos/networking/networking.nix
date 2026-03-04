{
  flake.modules.nixos.networking = {lib, ...}: {
    networking = {
      networkmanager.enable = true;
      nftables.enable = true;
      firewall.enable = true;
      useDHCP = lib.mkDefault true;
    };
  };
}
