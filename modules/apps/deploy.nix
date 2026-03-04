{
  inputs,
  lib,
  ...
}: {
  perSystem = {pkgs, ...}: {
    apps =
      lib.mapAttrs' (host: _: {
        name = "deploy-${host}";
        value = {
          type = "app";
          program = toString (pkgs.writeShellScript "deploy-${host}" ''
            nixos-rebuild switch --flake .#${host} --build-host root@monolith --target-host root@${host}
          '');
        };
      })
      inputs.self.nixosConfigurations;
  };
}
