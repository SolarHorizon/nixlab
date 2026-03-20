{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.nixlab.looking-glass;
in {
  options.nixlab.looking-glass = {
    enable = lib.mkEnableOption "Enable Looking Glass Client";
    enableKvmfr = lib.mkEnableOption "Enable IVSHMEM Support";
  };

  config = lib.mkIf cfg.enable {
    boot = lib.mkIf cfg.enableKvmfr {
      extraModulePackages = with config.boot.kernelPackages; [kvmfr];
      extraModprobeConfig = ''
        options kvmfr static_size_mb=256
      '';
      initrd = {
        kernelModules = ["kvmfr"];
      };
    };

    environment.systemPackages = with pkgs; [
      looking-glass-client
    ];

    environment.etc."looking-glass-client.ini" = {
      user = "+${toString config.users.users.matt.uid}";
      source = ./client.ini;
    };

    services.udev.extraRules = lib.mkIf cfg.enableKvmfr ''
      SUBSYSTEM=="kvmfr", OWNER="qemu-libvirtd", GROUP="kvm", MODE="0660"
    '';

    systemd.tmpfiles.settings = lib.mkIf (!cfg.enableKvmfr) {
      "looking-glass" = {
        "/dev/shm/looking-glass".f = {
          age = "-";
          group = "kvm";
          mode = "0660";
          user = "+${toString config.users.users.matt.uid}";
        };
      };
    };

    virtualisation.libvirtd.qemu.verbatimConfig = ''
      cgroup_device_acl = [
        ${lib.optionalString cfg.enableKvmfr "\"/dev/kvmfr0\","}
        "/dev/vfio/vfio", "/dev/vfio/23", "/dev/vfio/24",
        "/dev/null", "/dev/full", "/dev/zero",
        "/dev/random", "/dev/urandom",
        "/dev/ptmx", "/dev/kvm"
      ]
    '';
  };
}
