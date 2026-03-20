{
  osConfig,
  lib,
  pkgs,
  ...
}:
lib.mkIf (lib.hasAttr "wsl" osConfig && osConfig.wsl.enable) {
  home.sessionVariables = {
    OPENER = "wsl-open";
  };

  home.packages = with pkgs; [
    local.wsl-open
  ];
}
