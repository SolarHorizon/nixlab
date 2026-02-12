{
  flake.modules.nixvim.default = {pkgs, ...}: {
    extraPackages = with pkgs; [
      ripgrep
    ];

    keymaps = [
      {
        mode = "n";
        key = "T";
        action = "<cmd>Neotree toggle<CR>";
        options = {
          silent = true;
          desc = "Toggle Neotree";
        };
      }
      {
        mode = "n";
        key = "<leader>dl";
        action = "<cmd>Telescope diagnostics<CR>";
        options = {
          silent = true;
          desc = "Code action";
        };
      }
    ];

    plugins.neo-tree = {
      enable = true;
      settings = {
        close_if_last_window = true;
        popup_border_style = "rounded";

        event_handlers = [
          {
            event = "file_open_requested";
            handler.__raw = ''
              function()
              	require("neo-tree.command").execute({ action = "close" })
              end
            '';
          }
        ];

        filesystem = {
          filtered_items = {
            force_visible_in_empty_folder = true;
            follow_current_file = {
              enabled = true;
              leave_dirs_open = true;
            };
            always_show = [
              ".lune"
              ".storybook"
              ".env"
            ];
            hide_by_name = [
              "node_modules"
            ];
            hide_by_pattern = [
              "*.lock"
            ];
          };
        };

        buffers.follow_current_file.enabled = true;
      };
    };

    plugins.telescope = {
      enable = true;
      keymaps = {
        "<leader>ff" = {
          action = "find_files";
          options = {
            desc = "Find File";
          };
        };
        "<leader>fg" = {
          action = "live_grep";
          options = {
            desc = "Live Grep";
          };
        };
        "<leader>fr" = {
          action = "old_files";
          options = {
            desc = "Recent Files";
          };
        };
        "<C-p>" = {
          action = "find_files";
          options = {
            desc = "Find File";
          };
        };
        "<C-g>" = {
          action = "live_grep";
          options = {
            desc = "Live Grep";
          };
        };
      };
    };
  };
}
