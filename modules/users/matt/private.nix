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

  flake.modules.homeManager.matt-private = {
    config,
    lib,
    ...
  }: {
    sops.secrets = {
      "ssh/deploy_key" = {};
      "ssh/id_ed25519_sk" = {};
      "ssh/id_ed25519_sk_backup" = {};
      "ssh/wallow_key" = {};
    };

    programs.ssh.matchBlocks."wallow" = lib.hm.dag.entryBefore ["*"] {
      hostname = "192.168.0.36";
      user = "matt";
      identityFile = [
        config.sops.secrets."ssh/wallow_key".path
      ];
    };

    programs.ssh.matchBlocks."*".identityFile = [
      config.sops.secrets."ssh/id_ed25519_sk".path
      config.sops.secrets."ssh/id_ed25519_sk_backup".path
      config.sops.secrets."ssh/deploy_key".path
    ];

    programs.git.settings.user = {
      email = "matt@solarhorizon.dev";
      name = "Matt";
    };
  };
}
