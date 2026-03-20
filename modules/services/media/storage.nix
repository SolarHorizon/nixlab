# TODO: automatically set up nfs share when storage server != media server
{self, ...}: let
  host = "monolith";
in {
  flake.modules.nixos.media-storage = {
    config,
    pkgs,
    ...
  }: let
    inherit (config.media-server) group gid;
  in {
    environment.systemPackages = with pkgs; [
      mergerfs
      mergerfs-tools
      sshfs
    ];

    # TODO: migrate to big zfs pool
    fileSystems."/mnt/mergerfs" = {
      fsType = "fuse.mergerfs";
      device = "/mnt/disk/*";
      options = [
        "moveonenospc=true"
        "minfreespace=250G"
        "fsname=mergerfs"
      ];
    };

    # TODO: set up syncthing instead of sshfs (it's really slow + can drop old ssh key)
    fileSystems."/mnt/whatbox" = {
      device = "solarhrzn@ulysses.whatbox.ca:data";
      fsType = "sshfs";
      options = [
        "allow_other"
        "idmap=user"
        "gid=${toString gid}"
        "_netdev"
        "nodev"
        "noatime"
        "x-systemd.automount"
        "reconnect"
        "cache_timeout=3600"
        "ServerAliveInterval=15"
        "ServerAliveCountMax=3"
        "IdentityFile=/root/.ssh/id_ed25519"
      ];
    };

    systemd.tmpfiles.rules = [
      "d /mnt/mergerfs/media 2775 root ${group} -"
      "d /mnt/mergerfs/media/movies 2775 root ${group} -"
      "d /mnt/mergerfs/media/tv 2775 root ${group} -"
    ];
  };

  flake.modules.nixos.${host} = {
    imports = [
      self.modules.nixos.media-storage
    ];
  };
}
