{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    devShells.default = pkgs.mkShell {
      packages = [
        inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.claude-code

        (pkgs.writeShellScriptBin "build-host" ''
          set -euo pipefail
          host="''${1:?Usage: build <host>}"
          nix build ".#nixosConfigurations.$host.config.system.build.toplevel" "''${@:2}"
        '')
      ];
    };
  };
}
