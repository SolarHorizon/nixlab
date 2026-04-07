{
  dockerTools,
  pkgs,
}: let
  cacheUrl = "https://cache.matt.you/nixlab";
  cachePublicKey = "nixlab:vilT3iOpIuRLcVUs2EGxl4njjVNlM5oaundgBhOXj60=";
  imageName = "git.matt.you/matt/nix-ci-runner";
  imageTag = "latest";
in
  dockerTools.buildLayeredImage {
    name = imageName;
    tag = imageTag;
    contents = with pkgs; [
      nix
      attic-client
      bash
      coreutils
      curl
      gawk
      git
      gnused
      nodejs
      wget
      cacert
    ];
    config = {
      Env = [
        "NIX_CONFIG=experimental-features = nix-command flakes pipe-operators\nextra-substituters = ${cacheUrl}\nextra-trusted-public-keys = ${cachePublicKey}"
        "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      ];
    };
  }
