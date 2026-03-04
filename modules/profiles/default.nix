{self, ...}: {
  flake.modules.nixos.profile-default = {
    imports = with self.modules.nixos; [
      profile-minimal
      home-manager
      test-vm
      networking
      sops
    ];
  };

  flake.modules.homeManager.profile-default = {
    imports = with self.modules.homeManager; [
      profile-minimal
      sops
    ];
  };
}
