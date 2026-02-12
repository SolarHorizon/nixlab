{
  flake.modules.homeManager.git = {pkgs, ...}: {
    home.packages = [pkgs.git];

    programs.git = {
      enable = true;
      lfs.enable = true;
      settings = {
        push.autoSetupRemote = true;
      };
    };
  };
}
