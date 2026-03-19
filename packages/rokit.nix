{
  rustPlatform,
  fetchFromGitHub,
  openssl,
  ...
}:
rustPlatform.buildRustPackage (finalAttrs: rec {
  pname = "rokit";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "rojo-rbx";
    repo = "rokit";
    rev = "v${version}";
    hash = "sha256-7DVToKKq3omZOlLMIcthAS8PdvJ4zaKKDAU5HbDIEJc=";
  };

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-117kiiZ3ELP6S7SpNHJUBqqCKkVucxjfSmtRE83Zm/8=";
})
