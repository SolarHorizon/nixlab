{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.nixlab.virtualization;

  virtiofsd = pkgs.virtiofsd.overrideAttrs (old: rec {
    version = "8fa5564fdd4d5296997fb054a5e3193e18a81bcf";

    src = pkgs.fetchFromGitLab {
      owner = "hreitz";
      repo = "virtiofsd-rs";
      rev = version;
      hash = "sha256-QjLOjH+AvF3I9ffLTRhEfwRKG7SIjTy9kQv3Q/it+hs=";
    };

    cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
      inherit src;
      hash = "sha256-reaVHbfrHj5iZjpRaB+nREctoS3ZLdl5WGIurpRqjZU=";
    };
  });
in {
  options.nixlab.virtualization = {
    enable = lib.mkEnableOption "Enable Virtualization";
    looking-glass.enable = lib.mkEnableOption "Enable Looking Glass";
    virtiofs.enable = lib.mkEnableOption "Enable VirtioFS";
    samba.enable = lib.mkEnableOption "Enable Samba share";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      [
        virt-manager
      ]
      ++ lib.optionals cfg.virtiofs.enable [
        virtiofsd
      ];

    users.users.matt.extraGroups = [
      "libvirtd"
      "kvm"
    ];

    services.samba = lib.mkIf cfg.samba.enable {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "security" = "user";
          "hosts allow" = "192.168.122. 127.0.0.1 localhost";
          "hosts deny" = "0.0.0.0/0";
          "guest account" = "nobody";
          "map to guest" = "bad user";
          "allow insecure wide links" = "yes";
        };
        vm = {
          "path" = "/mnt/samba/vm";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "yes";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "${config.users.users.matt.name}";
          "force group" = "users";
          "follow symlinks" = "yes";
          "wide links" = "yes";
        };
      };
    };

    services.samba-wsdd = lib.mkIf cfg.samba.enable {
      enable = true;
      openFirewall = true;
    };

    systemd.tmpfiles.rules = lib.mkIf cfg.samba.enable [
      "d /mnt/samba/vm 0770 ${config.users.users.matt.name} users -"
    ];

    networking.firewall.allowPing = true;

    nixlab.looking-glass = lib.mkIf cfg.looking-glass.enable {
      enable = true;
      enableKvmfr = true;
    };

    virtualisation.spiceUSBRedirection.enable = true;
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        # ovmf = {
        #   enable = true;
        #   packages = [
        #     (pkgs.OVMF.override {
        #       secureBoot = true;
        #       tpmSupport = true;
        #     }).fd
        #   ];
        # };
        vhostUserPackages = lib.mkIf cfg.virtiofs.enable [
          virtiofsd
        ];
      };
    };
  };
}
