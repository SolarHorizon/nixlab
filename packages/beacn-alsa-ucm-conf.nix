{pkgs}:
pkgs.alsa-ucm-conf.overrideAttrs {
  wttsrc = pkgs.fetchFromGitHub {
    owner = "alsa-project";
    repo = "alsa-ucm-conf";
    rev = "1b69ade9b6d7ee37a87c08b12d7955d0b68fa69d";
    hash = "sha256-7PxI1/vQhrYOneNNRQI1vflPLqfd/ug1MorsZSQ5B3U=";
  };
  postInstall = ''
    cp -R $wttsrc/ucm2/* $out/share/alsa/ucm2
  '';
}
