{self, ...}: {
  flake.modules.nixos.looking-glass = {config, ...}: {
    home-manager.sharedModules = with self.modules.homeManager; [
      looking-glass
    ];

    boot = {
      extraModulePackages = with config.boot.kernelPackages; [kvmfr];
      extraModprobeConfig = ''
        options kvmfr static_size_mb=256
      '';
      initrd = {
        kernelModules = ["kvmfr"];
      };
    };

    services.udev.extraRules = ''
      SUBSYSTEM=="kvmfr", OWNER="qemu-libvirtd", GROUP="kvm", MODE="0660"
    '';

    virtualisation.libvirtd.qemu.verbatimConfig = ''
      cgroup_device_acl = [
      	"/dev/kvmfr0",
      	"/dev/vfio/vfio",
      	"/dev/vfio/23",
      	"/dev/vfio/24",
      	"/dev/null",
      	"/dev/full",
      	"/dev/zero",
      	"/dev/random",
      	"/dev/urandom",
      	"/dev/ptmx",
      	"/dev/kvm"
      ]
    '';
  };

  flake.modules.homeManager.looking-glass = {
    programs.looking-glass-client = {
      enable = true;

      settings = {
        input = {
          rawMouse = "yes";
        };
        spice = {
          enable = true;
          audio = true;
        };
        win = {
          autoResize = "yes";
          quickSplash = "yes";
        };
      };
    };
  };
}
