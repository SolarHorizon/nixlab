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
    sops.secrets = {
      "ssh/id_ed25519" = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519";
        mode = "0600";
      };
      "ssh/id_ed25519_sk" = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519_sk";
        mode = "0600";
      };
      "ssh/id_ed25519_sk_backup" = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519_sk_backup";
        mode = "0600";
      };
    };

    programs.git.settings.user = {
      email = "matt@solarhorizon.dev";
      name = "Matt";
    };
  };
}
