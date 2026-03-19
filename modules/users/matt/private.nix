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
      "ssh/deploy_key" = {};
      "ssh/id_ed25519_sk" = {};
      "ssh/id_ed25519_sk_backup" = {};
    };

    # sops.secrets."ssh/deploy_key" = {
    #   path = "${config.home.homeDirectory}/.ssh/deploy_key";
    #   mode = "0600";
    # };

    programs.ssh.matchBlocks."*".identityFile = [
      config.sops.secrets."ssh/deploy_key".path
      config.sops.secrets."ssh/id_ed25519_sk".path
      config.sops.secrets."ssh/id_ed25519_sk_backup".path
    ];

    programs.git.settings.user = {
      email = "matt@solarhorizon.dev";
      name = "Matt";
    };
  };
}
