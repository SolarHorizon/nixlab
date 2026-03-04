{
  self,
  lib,
  ...
}: {
  options.flake.u2fKeys = lib.mkOption {
    type = lib.types.attrsOf (lib.types.listOf lib.types.str);
    default = {};
  };

  config.flake.modules.nixos.yubikey-gui = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      yubioath-flutter
    ];
  };

  config.flake.modules.nixos.yubikey = {
    config,
    pkgs,
    ...
  }:
    lib.mkMerge [
      (lib.mkIf config.services.openssh.enable {
        security.pam.sshAgentAuth.enable = true;
        security.sudo.extraConfig = ''
          Defaults env_keep+=SSH_AUTH_SOCK
        '';
      })
      {
        environment.systemPackages = with pkgs; [
          yubikey-manager
        ];

        services.udev.packages = [
          pkgs.yubikey-personalization
        ];

        services.fprintd.enable = false;

        services.pcscd = {
          enable = true;
          plugins = [pkgs.ccid];
        };

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
          # sudo.u2fAuth = true;
          su.u2fAuth = true;
          polkit-1.u2fAuth = true;
          kde.u2fAuth = true;
        };
      }
    ];
}
