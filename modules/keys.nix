{lib, ...}: {
  options.flake.keys = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        ssh = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
        };
        u2f = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
        };
      };
    });
    default = {};
  };
}
