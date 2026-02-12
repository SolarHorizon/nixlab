{
  flake.modules.nixvim.default.keymaps = [
    {
      mode = "n";
      key = "<leader>e";
      action.__raw = ''
        function()
        	return vim.diagnostic.open_float({ scope= "line" })
        end
      '';
      options = {
        desc = "Show diagnostic";
      };
    }
    {
      mode = "n";
      key = "<leader>ca";
      action.__raw = ''vim.lsp.buf.code_action'';
      options = {
        desc = "Code action";
      };
    }
    {
      mode = "n";
      key = "K";
      action.__raw = ''vim.lsp.buf.hover'';
      options = {
        desc = "Hover";
      };
    }
    {
      mode = "n";
      key = "<leader>ot";
      action = "<cmd>OverseerToggle<CR>";
      options = {
        desc = "Toggle Overseer";
      };
    }
  ];
}
