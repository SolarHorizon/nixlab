{self, ...}: {
  flake.modules.nixos.profile-server = {
    imports = with self.modules.nixos; [
      profile-cli
      yubikey-server
    ];
  };

  flake.modules.homeManager.profile-server = {
    imports = with self.modules.homeManager; [
      profile-cli
    ];
  };
}
