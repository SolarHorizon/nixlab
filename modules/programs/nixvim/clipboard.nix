{
  flake.modules.nixvim.default = {pkgs, ...}: {
    extraPackages = with pkgs; [
      wl-clipboard
    ];

    clipboard.providers.wl-copy.enable = true;
  };
}
