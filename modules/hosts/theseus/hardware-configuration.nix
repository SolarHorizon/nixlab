{
  self.modules.nixos.theseus = {
    config,
    lib,
    modulesPath,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot.initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "thunderbolt"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];

    boot.initrd.kernelModules = [
      "vfio"
      "vfio_pci"
      "vfio_iommu_type1"
      "i915"
      # "amdgpu"
    ];

    boot.kernelParams = [
      "amd_iommu=on"
      "iommu=pt"
      # "vfio-pci.ids=8086:56a5,8086:4f92" # A380
      "vfio-pci.ids=8086:e20b,8086:e2f7" # B580
      # "quiet"
      # "splash"
    ];

    boot.kernelModules = ["kvm-amd"];
    boot.extraModulePackages = [];
    boot.supportedFilesystems = ["ntfs"];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/4a2314ad-2723-4f6b-8be3-57b0c03c3303";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/B8BE-6615";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };

    fileSystems."/mnt/games" = {
      device = "/dev/disk/by-uuid/6d2e8ebf-e14a-43ac-9e24-6b8e31dacfb5";
      fsType = "ext4";
    };

    fileSystems."/mnt/bulk-storage" = {
      device = "/dev/disk/by-uuid/5E241CC0241C9CD9";
      fsType = "ntfs-3g";
      options = ["rw" "uid=1000"];
    };

    swapDevices = [
      {device = "/dev/disk/by-uuid/b14c69c6-8379-40fe-9996-9eab5e1f483a";}
    ];

    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
