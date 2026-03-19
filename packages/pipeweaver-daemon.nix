{
  fetchFromGitHub,
  rustPlatform,
  pkgs,
  lib,
}: let
  pname = "pipeweaver-daemon";
  version = "0-unstable-2025-12-30";

  src = fetchFromGitHub {
    owner = "pipeweaver";
    repo = "pipeweaver";
    rev = "915a8838a0c5abe13ede870773f298889cd5a288";
    hash = "sha256-nZVXoqQWoKqkUjaiS/fsSoz2IB0Zs0ZSXUli0A7GrnA=";
  };

  web-ui = pkgs.buildNpmPackage {
    pname = "${pname}-web";
    version = "unstable";
    src = src + "/web";
    npmDepsHash = "sha256-lq/ZVHYNpBUbKZnUbrC+QmpXt1SlLRkyGqhBX+ubeoA=";
    buildPhase = "npm run build";
    installPhase = ''
      mkdir -p $out/daemon/web-content
      cp -r dist/* $out/daemon/web-content
    '';
  };

  desktopItem = pkgs.makeDesktopItem {
    name = "${pname}";
    desktopName = "Pipeweaver Daemon";
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
      web-ui
      desktopItem
      ;

    nativeBuildInputs = with pkgs; [
      git
      qt6.qtbase
      qt6.qtdeclarative
      qt6.wrapQtAppsHook
      qt6.qtwebengine
      pkg-config
      clang
      glibc
      llvmPackages.libclang
    ];

    buildInputs = with pkgs; [
      pipewire
      qt6.qtbase
      qt6.qtdeclarative
      qt6.qtwebengine
    ];

    cargoHash = "sha256-PI6cnbFj9oO4ES2zgw52Ez5WU5HMY/5xQWOLA0EOKs8=";

    postPatch = ''
      cat > daemon/build.rs <<'EOF'
       fn main() {}
      EOF

      ln -s ${web-ui}/daemon/web-content daemon/web-content

      export GIT_HASH=$(git rev-parse --short HEAD)
    '';

    postInstall = ''
      wrapProgram $out/bin/pipeweaver-daemon \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}"

      mkdir $out/share
      ln -s ${desktopItem}/share/applications $out/share/applications
    '';

    env.LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
  }
