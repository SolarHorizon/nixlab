{
  flake.modules.nixos.grub = {
    boot.loader.grub.enable = true;
    boot.loader.grub.device = "nodev";
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.efi.efiSysMountPoint = "/boot";
  };
}
