# mostly based on:
# https://pyproject-nix.github.io/uv2nix/usage/hello-world.html
{
  description = "Python XOR neural net Example Project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
          lib,
          system,
          ...
        }:
        let
          workspace = inputs.uv2nix.lib.workspace.loadWorkspace {
            workspaceRoot = ./.;
          };

          overlay = workspace.mkPyprojectOverlay {
            sourcePreference = "wheel";
          };

          pyprojectOverrides = _final: _prev: { };

          python = pkgs.python312;

          pythonSet =
            (pkgs.callPackage inputs.pyproject-nix.build.packages {
              inherit python;
              stdenv = pkgs.stdenv.override (
                lib.optionalAttrs pkgs.stdenv.isDarwin {
                  targetPlatform = pkgs.stdenv.targetPlatform // {
                    # https://pyproject-nix.github.io/uv2nix/platform-quirks.html
                    darwinSdkVersion = "15.1";
                  };
                }
              );
            }).overrideScope
              (
                lib.composeManyExtensions [
                  inputs.pyproject-build-systems.overlays.default
                  overlay
                  pyprojectOverrides
                ]
              );
        in
        {
          devShells.default =
            # special shell that runs the package in "editable mode"!
            let
              # Create an overlay enabling editable mode for all local dependencies.
              editableOverlay = workspace.mkEditablePyprojectOverlay {
                root = "$REPO_ROOT";
              };

              # Override previous set with our overrideable overlay.
              editablePythonSet = pythonSet.overrideScope (
                lib.composeManyExtensions [
                  editableOverlay

                  (final: prev: {
                    hello-world = prev.hello-world.overrideAttrs (old: {
                      src = lib.fileset.toSource {
                        root = old.src;
                        fileset = lib.fileset.unions [
                          (old.src + "/pyproject.toml")
                          (old.src + "/xor_neural_net/__init__.py")
                        ];
                      };
                      nativeBuildInputs = old.nativeBuildInputs ++ final.resolveBuildSystem { editables = [ ]; };
                    });

                  })
                ]
              );

              virtualenv = editablePythonSet.mkVirtualEnv "xor-neural-net" workspace.deps.all;

            in
            pkgs.mkShell {
              packages = [
                virtualenv
                pkgs.uv
                self'.formatter
              ];

              env = {
                # Don't create venv using uv
                UV_NO_SYNC = "1";

                # Force uv to use nixpkgs Python interpreter
                UV_PYTHON = python.interpreter;

                # Prevent uv from downloading managed Python's
                UV_PYTHON_DOWNLOADS = "never";
              };

              shellHook = ''
                # Undo dependency propagation by nixpkgs.
                unset PYTHONPATH

                export REPO_ROOT=$(git rev-parse --show-toplevel)
              '';
            };

          packages = {
            default = self'.packages.xor-neural-net;

            xor-neural-net = pythonSet.mkVirtualEnv "xor-neural-net" workspace.deps.default;
          };

          checks = self'.packages;

          apps.update-deps = {
            type = "app";
            program = pkgs.writeShellScriptBin "update-project-deps" ''
              ${pkgs.nix}/bin/nix flake update
              ${pkgs.uv}/bin/uv sync -U

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
