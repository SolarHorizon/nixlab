{inputs, ...}: {
  perSystem = {
    system,
    pkgs,
    ...
  }: {
    devShells.default = pkgs.mkShell {
      packages = with pkgs; [
        inputs.claude-code-nix.packages.${system}.claude-code
        gh
        jq
        age
        sops
        ssh-to-age
        ssh-to-pgp
        deploy-rs
      ];
    };
  };
}
