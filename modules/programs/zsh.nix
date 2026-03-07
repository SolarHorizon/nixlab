{lib, ...}: {
  flake.modules.nixos.zsh = {pkgs, ...}: {
    environment.shells = [
      pkgs.zsh
    ];

    users.defaultUserShell = pkgs.zsh;

    programs.zsh = {
      enable = true;
      enableLsColors = true;
      enableBashCompletion = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      interactiveShellInit = lib.mkAfter ''
        if [[ -n $SSH_CONNECTION ]]; then
        	PROMPT="%{$fg_bold[yellow]%}%m%{$reset_color%} $PROMPT"
        fi
      '';
    };

    programs.zsh.ohMyZsh = {
      enable = true;
      theme = "simple";
      plugins = [
        "command-not-found"
        "ssh"
      ];
    };

    programs.direnv.enable = true;
    programs.direnv.enableZshIntegration = true;
  };

  flake.modules.homeManager.zsh = {
    programs.zsh.enable = true;
  };
}
