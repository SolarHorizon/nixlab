{lib, ...}: {
  flake.modules.nixos.limine = {
    pkgs,
    config,
    ...
  }: {
    environment.systemPackages = with pkgs; [
      sbctl
    ];

    boot.loader.limine = {
      enable = true;

      style = {
        interface = {
          branding = config.networking.hostName;
        };
        wallpapers = with pkgs; [
          nixos-artwork.wallpapers.simple-dark-gray-bottom.kdeFilePath
        ];
      };
    };

    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.systemd-boot.enable = lib.mkForce false;
  };
}
