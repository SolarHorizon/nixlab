{inputs, ...}: {
  flake.modules.nixos.minecraft = {pkgs, ...}: {
    imports = [
      inputs.nix-minecraft.nixosModules.minecraft-servers
    ];

    nixpkgs.overlays = [
      inputs.nix-minecraft.overlay
    ];

    environment.systemPackages = with pkgs; [
      tmux
    ];

    sops.secrets."velocity/forwardingSecret" = {
      owner = "minecraft";
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
