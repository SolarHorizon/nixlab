{self, ...}: {
  flake.modules.nixos.nomad = {
    imports = with self.modules.nixos; [
      matt-private
    ];

    home-manager.users.matt = {
      home.stateVersion = "25.11";
    };
  };
}
