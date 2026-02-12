{
  self,
  lib,
  ...
}: {
  options.flake.u2fKeys = lib.mkOption {
    type = lib.types.attrsOf (lib.types.listOf lib.types.str);
    default = {};
  };

  config.flake.modules.nixos.yubikey = {pkgs, ...}: {
    services.udev.packages = [pkgs.yubikey-personalization];

    security.pam.u2f = {
      enable = true;
      settings = {
        origin = "pam://yubi";
        cue = true;
        cue_prompt = "Touch your security key";
        authfile = pkgs.writeText "u2f-mappings" (
          let
            users =
              lib.sort lib.lessThan (lib.attrNames
                self.u2fKeys);

            lines =
              map (
                user:
                  user + lib.concatStrings self.u2fKeys.${user}
              )
              users;
          in
            lib.concatStringsSep "\n" lines + "\n"
        );
      };
    };

    security.pam.services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
      sudo.fprintAuth = false;
    };
  };
}
