{self, ...}: {
  flake.modules.nixos.theseus = {config, ...}: {
    imports = with self.modules.nixos; [
      matt-private
    ];

    sops.secrets."users/matt/hashedPassword".neededForUsers = true;

    users.users.matt = {
      hashedPasswordFile = config.sops.secrets."users/matt/hashedPassword".path;
      extraGroups = [
        "input" # TODO: figure out how to get sunshine service module to handle this
      ];
    };

    home-manager.users.matt = {
      imports = with self.modules.homeManager; [
        minecraft
        libreoffice
        protontricks
        alsa-scarlett-gui
        unstable.r2modman
        retroarch-full
      ];

      home.stateVersion = "25.11";
    };
  };
}
