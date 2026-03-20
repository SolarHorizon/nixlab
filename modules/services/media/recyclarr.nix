{self, ...}: let
  host = "monolith";
in {
  flake.modules.nixos.recyclarr = {pkgs, ...}: {
    services.recyclarr = {
      enable = true;
      package = pkgs.unstable.recyclarr;
    };
  };

  flake.modules.nixos.${host} = {
    imports = with self.modules.nixos; [
      recyclarr
    ];
  };
}
