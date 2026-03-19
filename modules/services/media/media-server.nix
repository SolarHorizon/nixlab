{
  self,
  lib,
  ...
}: {
  flake.modules.generic.media-server = {
    options.media-server = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      default = {};
    };

    config.media-server = {
      group = "media";
      gid = 16778;
    };
  };

  flake.modules.nixos.media-server = {config, ...}: let
    inherit (config.media-server) group gid;
  in {
    imports = [
      self.modules.generic.media-server
    ];

    users.${group}.media = {
      inherit gid;
    };

    systemd.tmpfiles.rules = [
      "d /mnt/mergerfs/media 2775 root ${group} -"
      "d /mnt/mergerfs/media/movies 2775 root ${group} -"
      "d /mnt/mergerfs/media/tv 2775 root ${group} -"
    ];
  };
}
