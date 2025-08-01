{
  description = "Rust Hasher Example Project";

  inputs = {
    # this extra dependency can be dropped when not using IFD.
    # instead, just use pkgs.crate2nix from nixpkgs then
    crate2nix.url = "github:nix-community/crate2nix";
    crate2nix.inputs.nixpkgs.follows = "nixpkgs";
    crate2nix.inputs.flake-parts.follows = "flake-parts";

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
          lib,
          pkgs,
          self',
          system,
          ...
        }:
        let
          crate = import ./Cargo.nix { inherit pkgs lib; };
          crate-ifd = inputs.crate2nix.tools.${system}.appliedCargoNix {
            name = "hasher";
            src = lib.fileset.toSource {
              root = ./.;
              fileset = lib.fileset.unions [
                ./hasher
                ./hash-file
                ./hash-folder
                ./Cargo.toml
                ./Cargo.lock
              ];
            };
          };
        in
        {
          devShells.default = pkgs.mkShell {
            inputsFrom = [
              self'.packages.hash-file
            ];
            packages = [
              pkgs.clippy
              inputs.crate2nix.packages.${system}.default
              self'.formatter
            ];
          };

          packages = {
            default = crate.allWorkspaceMembers;

            hash-file = crate.workspaceMembers.hash-file.build;
            hash-folder = crate.workspaceMembers.hash-folder.build;
            hasher = crate.workspaceMembers.hasher.build;

            hash-file-ifd = crate-ifd.workspaceMembers.hash-file.build;
            hash-folder-ifd = crate-ifd.workspaceMembers.hash-folder.build;
            hasher-ifd = crate-ifd.workspaceMembers.hasher.build;
          };

          checks = self'.packages // {

            overlay-hash-file = pkgs.hash-file;
            overlay-hash-folder = pkgs.hash-folder;
            overlay-hasher = pkgs.hasher;
          };

          apps.update-deps = {
            type = "app";
            program = pkgs.writeShellScriptBin "update-project-deps" ''
              ${pkgs.nix}/bin/nix flake update
              ${pkgs.cargo}/bin/cargo update --breaking -Z unstable-options
              ${inputs.crate2nix.packages.${system}.default}/bin/crate2nix generate

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
            settings.global.excludes = [
              "Cargo.nix"
            ];
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
