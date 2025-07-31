final: prev:
let
  crate = import ./Cargo.nix {
    pkgs = final;
  };
in
{
  hash-file = crate.workspaceMembers.hash-file.build;
  hash-folder = crate.workspaceMembers.hash-folder.build;
  hasher = crate.workspaceMembers.hasher.build;
}
