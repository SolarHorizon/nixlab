{self, ...}: {
  flake.factory.user = username: isAdmin: {
    nixos."${username}" = {
      lib,
      pkgs,
      config,
      ...
    }: {
      users.users."${username}" = {
        isNormalUser = true;
        description = "${username}";
        home = "/home/${username}";
        extraGroups =
          lib.optionals isAdmin [
            "wheel"
          ]
          ++ lib.optionals config.networking.networkmanager.enable [
            "networkmanager"
          ];
        shell = pkgs.zsh;
      };

      home-manager.users."${username}" = {
        imports = [
          self.modules.homeManager."${username}"
        ];
      };

      programs._1password-gui.polkitPolicyOwners =
        lib.mkIf
        config.programs._1password-gui.enable [username];
    };

    homeManager."${username}" = {
      home.username = "${username}";
    };
  };
}
