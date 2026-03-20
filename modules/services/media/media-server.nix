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

    users.groups.${group} = {
      inherit gid;
    };
  };
}
