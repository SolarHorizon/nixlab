{
  self,
  lib,
  ...
}: {
  flake.modules = lib.mkMerge [
    (self.factory.user "matt" true)
    {
      homeManager.matt = {
        imports = with self.modules.homeManager; [
          nixvim
          zsh
          git
        ];

        programs.git.settings.user = {
          email = "matt@solarhorizon.dev";
          name = "Matt";
        };

        home.stateVersion = "25.11";
      };
    }
  ];

  flake.u2fKeys.matt = [
    ":EyhV/+JTUsPj3jyjRCGWgNV4QIkW/N6C7p9DfnYdrDzQApNmWEWxumsYOQ68yCVLUwlScekpQvsFKW+daJ/leQ==,XG2/vJE6ScyDDrsGC945QublNOjvfUHDvpNDGP3V8dxgcbXrG/qisp7SVi2eioJy69IwT1Fo0u+4uoXIq+b8LQ==,es256,+presence"
    ":GzO/PoXDX3lo83B1HRjJREFJ/A1MI7dcLLCLyEp9QoLGdD8Hu1QbuKBZFENHmwRQopVPjyS5gnNYDvH7ygshJA==,jCiqkVKaF1H40dwmn8JDB6aMGDF9QsKSq8Zei+8HzOSZ5JApft7RWiZP48Fi7XJJ8ltK2SerBurK+qsrTvzVUA==,es256,+presence"
  ];

  flake.homeConfigurations = self.lib.mkHomeManager "x86_64-linux" "matt";
}
