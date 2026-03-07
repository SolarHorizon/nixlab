{self, ...}: {
  flake.modules.nixos.ssh = {
    services.openssh = {
      enable = true;
      settings = {
        AllowAgentForwarding = true;
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };

  flake.modules.homeManager.ssh = {
    lib,
    osConfig,
    ...
  }: {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = lib.mkMerge [
        {
          "*" = {
            addKeysToAgent = "yes";
            hashKnownHosts = true;
          };
        }
        (lib.mkIf (osConfig != null && osConfig.services.tailscale.enable) (
          lib.mapAttrs'
          (name: _: {
            name = name;
            value.forwardAgent = true;
          })
          (lib.filterAttrs (name: cfg: cfg.config.services.tailscale.enable)
            self.nixosConfigurations)
        ))
      ];
    };
  };
}
