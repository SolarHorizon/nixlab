{
  flake.modules.nixos.profile-minimal = {
    pkgs,
    lib,
    ...
  }: {
    i18n.defaultLocale = "en_US.UTF-8";
    time.timeZone = "America/New_York";

    nixpkgs.config.allowUnfree = true;

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  };

  flake.modules.homeManager.profile-minimal = {
    config,
    pkgs,
    lib,
    ...
  }: {
    home.homeDirectory =
      if pkgs.stdenv.isDarwin
      then
        (lib.mkForce
          "/Users/${config.home.username}")
      else "/home/${config.home.username}";
  };
}
