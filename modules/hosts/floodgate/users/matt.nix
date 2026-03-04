{self, ...}: {
  flake.modules.nixos.floodgate = {
    imports = with self.modules.nixos; [
      matt
    ];

    home-manager.users.matt = {
      home.stateVersion = "25.11";
    };
  };
}
