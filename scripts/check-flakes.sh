#!/usr/bin/env bash

set -euo pipefail

find . -mindepth 2 -maxdepth 2 -name flake.nix | while read path; do
  repo=$(dirname $path)
  pushd $repo
  nix flake check -L  || { echo "Flake $repo failed" ; exit 1; }
  popd
done
