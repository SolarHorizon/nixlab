{self, ...}: {
  flake.modules.nixos.framework = {config, ...}: {
    imports = with self.modules.nixos; [
      matt-private
    ];

    sops.secrets."users/matt/hashedPassword".neededForUsers = true;

    users.users.matt = {
      hashedPasswordFile = config.sops.secrets."users/matt/hashedPassword".path;
    };

    home-manager.users.matt = {
      home.stateVersion = "25.11";
    };
  };
}
