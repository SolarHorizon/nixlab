{lib, ...}: {
  flake.modules.nixos.profile-minimal = {pkgs, ...}: {
    i18n.defaultLocale = "en_US.UTF-8";
    time.timeZone = "America/New_York";

    nixpkgs.config.allowUnfree = true;

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  };
}
