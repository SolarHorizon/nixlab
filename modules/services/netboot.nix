{self, ...}: let
  host = "monolith";
  domain = "netboot.matt.you";
  webUiPort = 3000;
  httpAssetsPort = 8080;
  user = "netboot";
  uid = 140;
  group = user;
  gid = uid;
  dataDir = "/srv/netboot";
in {
  flake.modules.nixos.netboot = {
    config,
    pkgs,
    ...
  }: {
    sops.secrets."netboot/smb_password" = {
      sopsFile = ../../secrets/services/netboot.yaml;
    };

    systemd.services.netboot-smbpasswd = {
      description = "Set Samba password for matt (netboot share)";
      after = ["samba-smbd.service"];
      requires = ["samba-smbd.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        password=$(cat ${config.sops.secrets."netboot/smb_password".path})
        printf '%s\n%s\n' "$password" "$password" | ${pkgs.samba}/bin/smbpasswd -s -a matt
      '';
    };

    users.groups."${group}".gid = gid;
    users.users."${user}" = {
      isSystemUser = true;
      group = group;
      uid = uid;
    };

    systemd.tmpfiles.rules = [
      "d ${dataDir} 0755 ${user} ${group} -"
      "d ${dataDir}/config 0755 ${user} ${group} -"
      "d ${dataDir}/assets 0755 ${user} ${group} -"
    ];

    virtualisation.oci-containers.containers.netboot = {
      image = "ghcr.io/netbootxyz/netbootxyz:latest";
      environment = {
        PGID = toString gid;
        PUID = toString uid;
      };
      ports = [
        "69:69/udp"
        "${toString webUiPort}:${toString webUiPort}"
        "${toString httpAssetsPort}:80"
      ];
      volumes = [
        "${dataDir}/config:/config"
        "${dataDir}/assets:/assets"
      ];
      log-driver = "journald";
    };

    networking.firewall = {
      allowedTCPPorts = [
        webUiPort
        httpAssetsPort
      ];
      allowedUDPPorts = [
        69 # TFTP
      ];
    };

    services.samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "security" = "user";
          "guest account" = "nobody";
          "map to guest" = "bad user";
        };
        netboot = {
          "path" = "${dataDir}/assets";
          "browseable" = "yes";
          "read only" = "yes";
          "guest ok" = "yes";
          "write list" = "matt";
          "force user" = user;
          "force group" = group;
        };
      };
    };

    services.samba-wsdd = {
      enable = true;
      openFirewall = true;
    };
  };

  flake.modules.nixos.caddy-internal = self.lib.mkReverseProxy {
    inherit domain host;
    port = webUiPort;
  };

  flake.modules.nixos.${host} = {
    imports = with self.modules.nixos; [
      netboot
    ];
  };
}
