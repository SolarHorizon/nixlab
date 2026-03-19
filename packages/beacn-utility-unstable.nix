{
  callPackage,
  dbus,
  fetchFromGitHub,
  libGL,
  libusb1,
  libxkbcommon,
  rustPlatform,
  wayland,
  xorg,
  makeWrapper,
  lib,
  pkgs,
}: let
  pname = "beacn-utility";
  version = "0.1.1-unstable-2025-12-03";
  src = fetchFromGitHub {
    owner = "beacn-on-linux";
    repo = "beacn-utility";
    rev = "83fa2c7e0440a888ede9e3b03ad0a13a1e659daa";
    hash = "sha256-We3GcEBA/bogeAkH136QFjeeEGAmfDLCbIFRfGJmEi8=";
  };

  fenix = callPackage (fetchFromGitHub {
    owner = "nix-community";
    repo = "fenix";
    rev = "451f184de2958f8e725acba046ec10670dd771a1";
    hash = "sha256-EA7Qh5OUc3tgYrLHfG7zU6wxltvWsJ0+sFxOcVsbjOY=";
  }) {};

  appId = "io.github.beacn_on_linux.${pname}";

  desktopItem = pkgs.makeDesktopItem {
    name = appId;
    desktopName = "Beacn Utility";
    comment = "Control interface for BEACN hardware";
    exec = pname;
    icon = "beacn-utility";
    categories = ["Utility"];
    terminal = false;
    startupWMClass = appId;
  };
in
  rustPlatform.buildRustPackage rec {
    inherit
      pname
      version
      src
      desktopItem
      ;

    cargoHash = "sha256-UVp6dpGKEy6+LSOQUsiqXvRpQ04+AU0TLqrWVuCKEwc=";

    nativeBuildInputs = [
      fenix.default.toolchain
      pkgs.desktop-file-utils
      makeWrapper
    ];

    buildInputs = [
      dbus
      libGL
      libusb1
      libxkbcommon
      wayland
      xorg.libX11
      xorg.libXcursor
      xorg.libXi
      xorg.libXrandr
    ];

    postInstall = ''
      wrapProgram $out/bin/beacn-utility \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}"

      # Install icons
      install -Dm644 $src/resources/icons/beacn-utility.png $out/share/icons/hicolor/48x48/apps/beacn-utility.png
      install -Dm644 $src/resources/icons/beacn-utility-large.png $out/share/pixmaps/beacn-utility.png
      install -Dm644 $src/resources/icons/beacn-utility.svg $out/share/icons/hicolor/scalable/apps/beacn-utility.svg

      ln -s ${desktopItem}/share/applications $out/share/applications
    '';
  }
