# Bazel 🏗️ Nix ❄️

This is [Bazel.build](https://bazel.build) made available as a [Nix flake](https://nixos.org/).

Contrary to [Bazel in nixpkgs](https://search.nixos.org/packages?channel=unstable&show=bazel&query=bazel),
this is just a tiny wrapper around the official Bazel binary release from GitHub, not a rebuild from source.
This makes it trivial to upgrade.

## Usage

TODO; see e.g. https://github.com/enola-dev/enola/blob/main/flake.nix

## Contrib

    nix run . -- version
