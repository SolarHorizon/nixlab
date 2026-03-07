{self, ...}: {
  flake.modules.nixos.profile-cli = {config, ...}: {
    imports = with self.modules.nixos; [
      profile-default
      _1password
      ssh
      tailscale
      yubikey-cli
      zsh
    ];

    services.fwupd.enable = true;

    hardware.enableAllFirmware = config.nixpkgs.config.allowUnfree;
    hardware.enableRedistributableFirmware = config.nixpkgs.config.allowUnfree;
  };

  flake.modules.homeManager.profile-cli = {
    imports = with self.modules.homeManager; [
      profile-default
      ssh
      zsh
    ];
  };
}
