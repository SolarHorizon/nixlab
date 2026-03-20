{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.nixlab.looking-glass;
in {
  options.nixlab.looking-glass.enable = lib.mkEnableOption "Enable Looking Glass Client";

  config = lib.mkIf cfg.enable {
    programs.looking-glass-client = {
      enable = true;
      package = pkgs.looking-glass-client;

      settings = {
        rawMouse = "yes";

        spice = {
          enable = true;
          audio = true;
        };

        win = {
          autoResize = "yes";
          quickSplash = "yes";
          size = "2556x1432";
        };
      };
    };
  };
}
