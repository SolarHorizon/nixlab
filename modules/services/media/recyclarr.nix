{self, ...}: let
  host = "monolith";
in {
  flake.modules.nixos.recyclarr = {
    config,
    pkgs,
    ...
  }: {
    services.recyclarr = {
      enable = true;
      package = pkgs.unstable.recyclarr;
      group = config.media-server.group;
    };
  };

  flake.modules.nixos.${host} = {
    imports = with self.modules.nixos; [
      recyclarr
    ];
  };
}
