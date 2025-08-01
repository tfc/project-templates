{
  description = "Rust Hasher Example Project";

  inputs = {
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
          self',
          system,
          ...
        }:
        {
          devShells.default = pkgs.mkShell {
            inputsFrom = [
            ];
            packages = [
              self'.formatter
            ];
          };

          packages = {
            default = self'.packages.xor-neural-net;

            inherit (pkgs.python312Packages) xor-neural-net;
          };

          checks = self'.packages;

          apps.update-deps = {
            type = "app";
            program = pkgs.writeShellScriptBin "update-project-deps" ''
              ${pkgs.nix}/bin/nix flake update
              ${pkgs.cargo}/bin/cargo update --breaking -Z unstable-options

              sed -i "s/cargoHash = .*;/cargoHash = lib.fakeHash;/" package.nix
              CORRECT_HASH=$(nix build 2>&1 | awk '/got: /{print $NF}')
              sed -i "s/cargoHash = .*;/cargoHash = \"$CORRECT_HASH\";/" package.nix

              echo "Updated everything. Now build and test it. If it works - commit all changes!"
            '';
          };

          treefmt = {
            projectRootFile = "flake.lock";
            programs = {
              ruff-check.enable = true;
              ruff-format.enable = true;
              deadnix.enable = true;
              nixfmt.enable = true;
              shfmt.enable = true;
              statix.enable = true;
            };
          };

          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              inputs.self.overlays.default
            ];
            config = {
            };
          };
        };
      flake = {
        overlays.default = import ./overlay.nix;
      };
    };
}
