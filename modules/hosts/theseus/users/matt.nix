{self, ...}: {
  flake.modules.nixos.theseus = {
    config,
    pkgs,
    ...
  }: {
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
      ];

      home.packages = with pkgs; [
        protontricks
        alsa-scarlett-gui
        unstable.r2modman
        (retroarch.withCores (cores:
          with cores; [
            pcsx2
          ]))
      ];

      home.stateVersion = "25.11";
    };
  };
}
