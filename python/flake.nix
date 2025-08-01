# Study this to understand everything:
# https://nixos.org/manual/nixpkgs/stable/#python
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
          devShells.default =
            # Python dev shell in "editable mode":
            # https://nixos.org/manual/nixpkgs/stable/#mkpythoneditablepackage-function
            let
              pyproject = pkgs.lib.importTOML ./pyproject.toml;

              myPython = pkgs.python312.override {
                self = myPython;
                packageOverrides = pyfinal: _pyprev: {
                  xor-neural-net = pyfinal.mkPythonEditablePackage {
                    pname = pyproject.project.name;
                    inherit (pyproject.project) version;

                    root = "$REPO_ROOT";

                    inherit (pyproject.project) scripts;
                  };
                };
              };

              pythonEnv = myPython.withPackages (ps: [ ps.xor-neural-net ]);

            in
            pkgs.mkShell {
              packages = [
                pythonEnv
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
              # we're not using any lockfile or similar.
              # All pkgs are from nixpkgs, even the Python packages.

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
