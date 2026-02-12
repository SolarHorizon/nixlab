{self, ...}: {
  flake.modules.nixos.profile-default = {
    imports = with self.modules.nixos; [
      profile-minimal
      home-manager
      test-vm
      networking
    ];
  };
}
