{self, ...}: {
  flake.modules.nixos.role-base = {
    pkgs,
    lib,
    ...
  }: {
    imports = with self.modules.nixos; [
      home-manager
      test-vm
      sops
      zsh
    ];

    i18n.defaultLocale = "en_US.UTF-8";
    time.timeZone = "America/New_York";

    nixpkgs.config.allowUnfree = true;

    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];
      substituters = [
        "https://cache.matt.you/nixlab"
      ];
      trusted-public-keys = [
        "nixlab:vilT3iOpIuRLcVUs2EGxl4njjVNlM5oaundgBhOXj60="
      ];
      trusted-users = ["@wheel"];
    };

    services.fwupd.enable = lib.mkDefault true;

    networking = {
      nftables.enable = true;
      firewall.enable = true;
      useDHCP = lib.mkDefault true;
    };

    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  };

  flake.modules.homeManager.role-base = {
    config,
    pkgs,
    lib,
    ...
  }: {
    imports = with self.modules.homeManager; [
      sops
      ssh
      zsh
    ];

    home.homeDirectory =
      if pkgs.stdenv.isDarwin
      then
        (lib.mkForce
          "/Users/${config.home.username}")
      else "/home/${config.home.username}";
  };
}
