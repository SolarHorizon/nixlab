{
  fetchFromGitHub,
  rustPlatform,
  pkgs,
}: let
  pname = "pipeweaver-app";
  version = "0-unstable-2025-12-14";
  src = fetchFromGitHub {
    owner = "FrostyCoolSlug";
    repo = "pipeweaver-app";
    rev = "25b2854154cae053ff23cbd5ea74d757a75aa35e";
    hash = "sha256-6B9lnDKB+09ooHd05g628WmlUJ3TdPFUtPVFEux1CAg=";
  };

  desktopItem = pkgs.makeDesktopItem {
    name = "${pname}";
    desktopName = "Pipeweaver";
    exec = "${pname}";
    categories = ["Utility"];
    terminal = false;
    startupWMClass = "${pname}";
  };
in
  rustPlatform.buildRustPackage rec {
    inherit
      pname
      version
      src
      desktopItem
      ;

    nativeBuildInputs = with pkgs; [
      pkg-config
      qt6.wrapQtAppsHook
    ];

    buildInputs = with pkgs; [
      qt6.qtbase
      qt6.qtdeclarative
      qt6.qtwebengine
    ];

    cargoHash = "sha256-6f8ecF51R4rVL45xDqchLWbmm92uXVkK6AV+lJ5F5tg=";

    postInstall = ''
      mkdir -p $out/share
      ln -s ${desktopItem}/share/applications $out/share/applications
    '';

    # env.LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
  }
