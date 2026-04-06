{inputs, ...}: {
  flake.modules.homeManager.lan-mouse = {
    imports = [inputs.lan-mouse.homeManagerModules.default];

    programs.lan-mouse = {
      enable = true;
      systemd = true;
    };

    # why did they not do this themselves?
    systemd.user.services.lan-mouse.Install.WantedBy = ["graphical-session.target"];
  };
}
