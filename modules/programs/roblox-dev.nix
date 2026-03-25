{self, ...}: {
  flake.modules.nixos.roblox-dev = {
    imports = with self.modules.nixos; [
      windows-vm
      nix-ld
    ];

    home-manager.sharedModules = with self.modules.homeManager; [
      roblox-dev
    ];

    boot.kernel.sysctl."net.ipv4.conf.virbr0.route_localnet" = 1;

    networking.nftables.tables.jest-nat = {
      family = "ip";
      content = ''
        chain prerouting {
          type nat hook prerouting priority dstnat;
          iifname "virbr0" tcp dport 28860 dnat to 127.0.0.1:28860
        }
      '';
    };
  };

  flake.modules.homeManager.roblox-dev = {pkgs, ...}: {
    home.sessionPath = [
      "$HOME/.rokit/bin"
    ];

    home.packages = with pkgs; [
      local.rokit
    ];
  };
}
