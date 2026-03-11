{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    devShells.default = pkgs.mkShell {
      packages = [
        inputs.claude-code-nix.packages.${pkgs.system}.claude-code
      ];
    };
  };
}
