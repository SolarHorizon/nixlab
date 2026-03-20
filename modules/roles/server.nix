{self, ...}: {
  flake.modules.nixos.role-server = {
    imports = with self.modules.nixos; [
      role-base
      tailscale
      ssh
      yubikey-ssh
    ];
  };

  flake.modules.homeManager.role-server = {
    imports = with self.modules.homeManager; [
      role-base
    ];
  };
}
