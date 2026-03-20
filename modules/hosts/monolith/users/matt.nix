{self, ...}: {
  flake.modules.nixos.monolith = {
    imports = with self.modules.nixos; [
      matt
    ];

    home-manager.users.matt = {
      home.stateVersion = "24.05";
    };
  };
}
