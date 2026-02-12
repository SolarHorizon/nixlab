{
  inputs,
  self,
  lib,
  ...
}: {
  flake.modules.homeManager.nixvim = {
    imports = [
      inputs.nixvim.homeModules.nixvim
    ];

    programs.nixvim = {
      imports = [
        self.modules.nixvim.default
      ];
    };
  };

  flake.modules.nixvim.default = let
    genOpts = langs: opts:
      lib.genAttrs (
        lib.forEach langs (name: "ftplugin/${name}.lua")
      )
      opts;

    twoSpaceLangs =
      genOpts [
        "javascript"
        "javascriptreact"
        "typescript"
        "typescriptreact"
        "json"
        "jsonc"
        "json5"
        "nix"
      ] (_: {
        opts = {
          tabstop = 2;
          shiftwidth = 2;
          softtabstop = 2;
        };
      });
  in {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    luaLoader.enable = true;

    opts = {
      scrolloff = 6;
      tabstop = 4;
      shiftwidth = 4;
      softtabstop = 0;
      wrap = false;
      splitright = true;
      splitbelow = true;
      termguicolors = true;
      number = true;
      colorcolumn = "81";
      textwidth = 80;
      relativenumber = true;
      smartcase = true;
      ignorecase = true;
      incsearch = true;
      errorbells = true;
      signcolumn = "yes";
      exrc = true;
    };

    globals = {
      mapleader = " ";
    };

    files =
      twoSpaceLangs
      // {
        "ftplugin/luau.lua".opts = {
          tabstop = 4;
          shiftwidth = 4;
          softtabstop = 4;
        };
      };
  };
}
