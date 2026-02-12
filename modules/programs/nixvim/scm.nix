{
  flake.modules.nixvim.default = {
    plugins.gitsigns = {
      enable = true;
      settings = {
        current_line_blame = true;
      };
    };

    plugins.fugitive.enable = true;
  };
}
