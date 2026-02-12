{
  flake.modules.nixvim.default = {pkgs, ...}: {
    extraPackages = with pkgs; [
      selene
    ];

    plugins.neoconf.enable = true;
    plugins.neoconf.autoLoad = true;

    plugins.lsp.enable = true;
    plugins.lsp.servers.nixd.enable = true;

    plugins.lint = {
      enable = true;
      autoCmd.event = [
        "BufEnter"
        "BufWritePost"
        "TextChanged"
        "InsertLeave"
      ];
      lintersByFt = {
        luau = ["selene"];
        lua = ["selene"];
      };
    };
  };
}
