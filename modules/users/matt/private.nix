{self, ...}: {
  flake.modules.nixos.matt-private = {
    imports = with self.modules.nixos; [
      matt
    ];

    home-manager.users.matt = {
      imports = with self.modules.homeManager; [
        matt-private
      ];
    };
  };

  flake.modules.homeManager.matt-private = {config, ...}: {
    imports = with self.modules.homeManager; [
      deployment-auth
    ];

    sops.secrets = {
      "ssh/id_ed25519_sk" = {};
      "ssh/id_ed25519_sk_backup" = {};
    };

    programs.ssh.matchBlocks."*".identityFile = [
      config.sops.secrets."ssh/id_ed25519_sk".path
      config.sops.secrets."ssh/id_ed25519_sk_backup".path
    ];

    programs.git.settings.user = {
      email = "matt@solarhorizon.dev";
      name = "Matt";
    };
  };
}
