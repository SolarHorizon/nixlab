{
  flake.modules.homeManager.libreoffice = {pkgs, ...}: {
    home.packages = with pkgs; [
      libreoffice-qt
      hunspell
      hunspellDicts.en-us
    ];
  };
}
