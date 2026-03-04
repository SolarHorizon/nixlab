{
  self,
  lib,
  ...
}: {
  flake.modules = lib.mkMerge [
    (self.factory.user "matt" true)
    {
      nixos.matt = {
        users.users.matt.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDefgt/cvOaW9hc4cLDniEoFh9+N49DypQmB7hoTZ987"
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIEKgb6TlmKSuBHEb9HZ8hn6DLYbMXBOH6Gua9cSr2ZslAAAABHNzaDo= matt@yubikey-primary"
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDwzPPg/ESf2bVbbIwj1adbkVcmg4DeijjROk5A6oUIGAAAABHNzaDo= matt@yubikey-backup"
        ];
      };

      homeManager.matt = {
        imports = with self.modules.homeManager; [
          nixvim
          zsh
          git
        ];
      };
    }
  ];

  flake.u2fKeys.matt = [
    ":EyhV/+JTUsPj3jyjRCGWgNV4QIkW/N6C7p9DfnYdrDzQApNmWEWxumsYOQ68yCVLUwlScekpQvsFKW+daJ/leQ==,XG2/vJE6ScyDDrsGC945QublNOjvfUHDvpNDGP3V8dxgcbXrG/qisp7SVi2eioJy69IwT1Fo0u+4uoXIq+b8LQ==,es256,+presence"
    ":GzO/PoXDX3lo83B1HRjJREFJ/A1MI7dcLLCLyEp9QoLGdD8Hu1QbuKBZFENHmwRQopVPjyS5gnNYDvH7ygshJA==,jCiqkVKaF1H40dwmn8JDB6aMGDF9QsKSq8Zei+8HzOSZ5JApft7RWiZP48Fi7XJJ8ltK2SerBurK+qsrTvzVUA==,es256,+presence"
  ];

  flake.homeConfigurations = self.lib.mkHomeManager "x86_64-linux" "matt";
}
