{inputs, ...}: {
  flake.modules.nixos.minecraft = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      inputs.nix-minecraft.nixosModules.minecraft-servers
    ];

    nixpkgs.overlays = [
      inputs.nix-minecraft.overlay
    ];

    environment.systemPackages = with pkgs; [
      (writeShellScriptBin "mc-console" ''
        su minecraft -s $SHELL -c "tmux -S /run/minecraft/''${1}.sock attach"
      '')
      tmux
    ];

    sops.secrets."velocity/forwardingSecret" = {
      owner = "minecraft";
      sopsFile = ../../../../secrets/services/minecraft.yaml;
    };

    sops.templates."minecraft.env".content = ''
      forwardingSecret=${config.sops.placeholder."velocity/forwardingSecret"}
    '';

    services.minecraft-servers = {
      enable = true;
      eula = true;
      openFirewall = true;
      environmentFile = config.sops.templates."minecraft.env".path;
    };
  };

  flake.modules.homeManager.minecraft = {pkgs, ...}: {
    home.packages = with pkgs; [
      prismlauncher
    ];
  };

  flake.modules.homeManager.minecraft-tools = {pkgs, ...}: {
    home.packages = with pkgs; [
      packwiz
      mcaselector
    ];
  };
}
