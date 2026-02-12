{self, ...}: {
  flake.modules.nixos.profile-cli = {config, ...}: {
    imports = with self.modules.nixos; [
      profile-default
      zsh
      tailscale
      yubikey
      _1password
    ];

    services.fwupd.enable = true;

    hardware.enableAllFirmware = config.nixpkgs.config.allowUnfree;
    hardware.enableRedistributableFirmware = config.nixpkgs.config.allowUnfree;
  };

  flake.modules.homeManager.profile-cli = {
    imports = with self.modules.homeManager; [
      zsh
    ];
  };
}
