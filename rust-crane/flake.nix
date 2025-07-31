{
  description = "Rust Hasher Example Project";

  inputs = {
    crane.url = "github:ipetkov/crane";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      perSystem =
        {
          pkgs,
          lib,
          self',
          system,
          ...
        }:
        let
          craneLib = inputs.crane.mkLib pkgs;
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

          commonArgs = {
            pname = "hasher";
            inherit (craneLib.crateNameFromCargoToml { src = ./hash-file; }) version;

            inherit src;
            strictDeps = true;

            nativeBuildInputs = [ pkgs.pkg-config ];
            buildInputs = [ pkgs.openssl ];
          };

          cargoArtifacts = craneLib.buildDepsOnly commonArgs;

          individualCrateArgs = commonArgs // {
            inherit cargoArtifacts;
            doCheck = false;
          };

          hash-file = craneLib.buildPackage (
            individualCrateArgs
            // {
              pname = "hash-file";
              cargoExtraArgs = "-p hash-file";
              inherit src;
            }
          );
          hash-folder = craneLib.buildPackage (
            individualCrateArgs
            // {
              pname = "hash-folder";
              cargoExtraArgs = "-p hash-folder";
              inherit src;
            }
          );
        in
        {
          devShells.default = pkgs.mkShell {
            inputsFrom = [
              hash-file
            ];
            packages = [
              pkgs.clippy
              self'.formatter
            ];
          };

          packages = {
            default = self'.packages.hash-file;

            inherit
              hash-file
              hash-folder
              ;
          };

          checks = self'.packages // {
            my-workspace-clippy = craneLib.cargoClippy (
              commonArgs
              // {
                inherit cargoArtifacts;
                cargoClippyExtraArgs = "--all-targets -- --deny warnings";
              }
            );

            my-workspace-doc = craneLib.cargoDoc (
              commonArgs
              // {
                inherit cargoArtifacts;
              }
            );
          };

          apps.update-deps = {
            type = "app";
            program = pkgs.writeShellScriptBin "update-project-deps" ''
              ${pkgs.nix}/bin/nix flake update
              ${pkgs.cargo}/bin/cargo update --breaking -Z unstable-options

              echo "Updated everything. Now build and test it. If it works - commit all changes!"
            '';
          };

          treefmt = {
            projectRootFile = "flake.lock";
            programs = {
              deadnix.enable = true;
              nixfmt.enable = true;
              rustfmt.enable = true;
              shfmt.enable = true;
              statix.enable = true;
            };
          };

          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              inputs.self.overlays.default
            ];
            config = { };
          };
        };
      flake = {
        overlays.default = import ./overlay.nix;
      };
    };
}
