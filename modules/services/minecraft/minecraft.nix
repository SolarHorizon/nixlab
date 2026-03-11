{inputs, ...}: {
  flake.modules.nixos.minecraft = {pkgs, ...}: let
  in {
    imports = [
      inputs.nix-minecraft.nixosModules.minecraft-servers
    ];

    nixpkgs.overlays = [
      inputs.nix-minecraft.overlay
    ];

    environment.systemPackages = with pkgs; [
      (writeShellScriptBin "mc-console" ''
        su minecraft -s $SHELL -c "tmux -S /run/minecraft/${1}.sock attach"
      '')
      tmux
    ];

    sops.secrets."velocity/forwardingSecret" = {
      owner = "minecraft";
      sopsFile = ../../../secrets/services/minecraft.yaml;
    };

    services.minecraft-servers = {
      enable = true;
      eula = true;
      openFirewall = true;
    };
  };

  flake.modules.homeManager.minecraft = {pkgs, ...}: {
    home.packages = with pkgs; [
      packwiz
      mcaselector
      prismlauncher
    ];
  };
}
