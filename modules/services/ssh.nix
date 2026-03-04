{
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

  flake.modules.homeManager.ssh = {osConfig, ...}: {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "*" = {
          hashKnownHosts = true;
        };
        "*.ts.net" = {
          forwardAgent = osConfig.services.tailscale.enable;
        };
      };
    };
  };
}
