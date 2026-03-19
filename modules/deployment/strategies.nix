{lib, ...}: {
  flake.modules.nixos.deployment-strategies = {
    hostConfig,
    pkgs,
    ...
  }: let
    autoUpdate = hostConfig.autoUpdate;
    enabled = autoUpdate.enable && autoUpdate.strategy == "push";
  in
    lib.mkMerge [
      # pull strategy
      (lib.mkIf enabled {
        system.autoUpgrade = {
          enable = true;
          flake =
            lib.throwIf (autoUpdate.flake == null)
            "`hosts.nixos.${hostConfig.name}.autoUpdate.flake` must be set when strategy is \"pull\""
            autoUpdate.flake;
          dates = "04:40";
          allowReboot = true;
          rebootWindow = {
            lower = "02:00";
            upper = "06:00";
          };
        };
      })

      # push strategy
      (lib.mkIf enabled {
        users.users.deploy = {
          isSystemUser = true;
          group = "deploy";
          shell = pkgs.bash;
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH1B4bByBCRr2ZUMOqRoiuCy6NtpWTOfbIq5mKPKPZkx deploy@nixlab"
          ];
        };

        users.groups.deploy = {};

        security.sudo.extraRules = [
          {
            users = ["deploy"];
            commands = [
              {
                command = "ALL";
                options = ["NOPASSWD"];
              }
            ];
          }
        ];

        nix.settings.trusted-users = ["deploy"];
      })
    ];
}
