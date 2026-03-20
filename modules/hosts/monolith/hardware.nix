{
  flake.modules.nixos.monolith = {
    fileSystems."/" = {
      device = "/dev/disk/by-uuid/4c60f641-38d9-475e-a25b-f39cb9070d44";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/1362-67EC";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };

    fileSystems."/mnt/disk/disk1" = {
      device = "/dev/disk/by-uuid/b27611e9-93a9-4582-b043-a1535e9520c8";
      fsType = "ext4";
    };

    fileSystems."/mnt/disk/disk2" = {
      device = "/dev/disk/by-uuid/f47a2b46-b6e1-4171-b9d1-1bd1fce54a69";
      fsType = "ext4";
    };

    swapDevices = [];

    hardware.facter.reportPath = ./facter.json;
  };
}
