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
}:
rustPlatform.buildRustPackage (finalAttrs: let
  fenix = callPackage (fetchFromGitHub {
    owner = "nix-community";
    repo = "fenix";
    rev = "451f184de2958f8e725acba046ec10670dd771a1";
    hash = "sha256-EA7Qh5OUc3tgYrLHfG7zU6wxltvWsJ0+sFxOcVsbjOY=";
  }) {};

  appId = "io.github.beacn_on_linux.beacn-utility";

  desktopItem = pkgs.makeDesktopItem {
    name = appId;
    desktopName = "Beacn Utility";
    comment = "Control interface for BEACN hardware";
    exec = "${finalAttrs.pname}";
    icon = "beacn-utility";
    categories = ["Utility"];
    terminal = false;
    startupWMClass = appId;
  };
in rec {
  pname = "beacn-utility";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "beacn-on-linux";
    repo = "beacn-utility";
    rev = "v${version}";
    hash = "sha256-THblb40jgBHot3HLjKoFr/jVx8gMBJIghaVQ5HEkBuw=";
  };

  cargoHash = "sha256-/5Lt7g2mdGuIgdtHcppOY2EzgOpHDQRmR9EL23KDuak=";

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
})
