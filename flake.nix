{
  description = "Nix Project templates";

  outputs = inputs: {
    templates = {
      python = {
        path = ./python;
        description = "Standard Python project with dependencies managed by nixpkgs";
      };
      python-uv2nix = {
        path = ./python-uv2nix;
        description = "Standard Python project with UV lockfile management";
      };

      rust = {
        path = ./rust;
        description = "Standard Rust project with nixpkgs-native Rust tooling";
      };
      rust-crate2nix = {
        path = ./rust-crate2nix;
        description = "Standard Rust project with crate2nix dependency management, with and without IFD";
      };
      rust-crane = {
        path = ./rust-crane;
        description = "Standard Rust project with Crane library management. Uses IFD.";
      };
    };
  };
}
