{
  flake.modules.nixvim.default = {
    colorschemes = {
      tokyonight = {
        enable = true;
        settings = {
          style = "storm";
          styles.comments.italic = true;
        };
      };
    };

    plugins.alpha = {
      enable = true;
      theme = "theta";
    };

    plugins.indent-blankline = {
      enable = true;
      settings.scope.enabled = false;
    };

    plugins.lualine = {
      enable = true;
      settings = {
        options = {
          component_separators = {
            left = "";
            right = "";
          };
          section_separators = {
            left = "";
            right = "";
          };
          globalstatus = true;
          theme = "tokyonight";
        };
        sections = {
          lualine_c = [
            {
              __unkeyed-1 = "filename";
              path = 1;
            }
          ];
          lualine_x = [
            {
              __unkeyed-1 = "overseer";
            }
          ];
        };
      };
    };

    plugins.noice = {
      enable = true;
      settings = {
        cmdline.enabled = false;
        messages.enabled = false;
        override = {
          "vim.lsp.util.convert_input_to_markdown_lines" = true;
          "vim.lsp.util.stylize_markdown" = true;
          "cmp.entry.get_documentation" = true;
        };
        presets = {
          bottom_search = true;
          command_palette = true;
          long_message_to_split = true;
          lsp_doc_border = true;
        };
        views.mini = {
          position = {
            row = -3;
          };
          win_options = {
            winblend = 0;
          };
        };
      };
    };

    plugins.web-devicons.enable = true;
    plugins.ccc.enable = true;

    plugins.notify.enable = true;
    plugins.dressing.enable = true;
  };
}
