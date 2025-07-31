{
  lib,
  rustPlatform,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage (_finalAttrs: {
  name = "hasher";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./Cargo.lock
      ./Cargo.toml
      ./hash-file
      ./hash-folder
      ./hasher
    ];
  };

  cargoHash = "sha256-ufq8z5v35KB4JbUgfpKrkTdkmimo62Tb1+5nmwh3UvQ=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
})
