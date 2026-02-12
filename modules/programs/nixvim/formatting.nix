{lib, ...}: {
  flake.modules.nixvim.default = {pkgs, ...}: {
    extraPackages = with pkgs; [
      stylua
      prettierd
      alejandra
      coreutils
    ];

    plugins.conform-nvim = let
      stylua = ["stylua"];

      prettier = {
        __unkeyed-1 = "prettierd";
        __unkeyed-2 = "prettier";
        stop_after_first = true;
      };
    in {
      enable = true;
      settings = {
        formatters_by_ft = {
          lua = stylua;
          luau = stylua;
          javascript = prettier;
          typescript = prettier;
          json = prettier;
          rust = ["rustfmt"];
          nix = ["alejandra"];
          _ = [
            "squeeze_blanks"
            "trim_whitespace"
            "trim_newlines"
          ];
        };
        format_on_save = {
          timeout_ms = 500;
          lsp_format = "fallback";
        };
        formatters = {
          stylua = {command = lib.getExe pkgs.stylua;};
          prettierd = {command = lib.getExe pkgs.prettierd;};
          alejandra = {command = lib.getExe pkgs.alejandra;};
          squeeze_blanks = {command = lib.getExe' pkgs.coreutils "cat";};
        };
      };
    };
  };
}
