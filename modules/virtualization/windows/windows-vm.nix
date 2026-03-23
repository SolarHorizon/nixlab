{self, ...}: {
  self.modules.nixos.windows-vm = {pkgs, ...}: {
    imports = with self.modules.nixos; [
      looking-glass
    ];

    environment.systemPackages = with pkgs; [
      virt-manager
    ];

    # TODO: fix hardcoded user
    users.users.matt.extraGroups = [
      "libvirtd"
      "kvm"
    ];

    virtualisation.spiceUSBRedirection.enable = true;

    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
      };
    };

    services.samba = {
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
          "force user" = "matt"; # TODO: fix hardcoded user
          "force group" = "users";
          "follow symlinks" = "yes";
          "wide links" = "yes";
        };
      };
    };

    services.samba-wsdd = {
      enable = true;
      openFirewall = true;
    };

    systemd.tmpfiles.rules = [
      "d /mnt/samba/vm 2770 matt users -" # TODO: fix hardcoded user
    ];

    networking.firewall.trustedInterfaces = ["virbr0"];
    networking.extraHosts = "192.168.122.98 shadow";
  };
}
