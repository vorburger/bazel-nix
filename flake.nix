{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      lib = nixpkgs.lib;
      systems = [ "x86_64-linux" ];
      forEachSystem = lib.genAttrs systems;
    in
    {
      packages = forEachSystem (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          bazel-binary = pkgs.stdenv.mkDerivation {
            pname = "bazel";
            version = "8.4.2";

            src = pkgs.fetchurl {
              url = "https://github.com/bazelbuild/bazel/releases/download/8.4.2/bazel-8.4.2-linux-x86_64";
              sha256 = "sha256-TcjpnfqALiUtrBdtCCAf0VxUKueMRIyKiZdLbzh8KCw=";
            };

            unpackPhase = ''
              # The source is a single binary file, not an archive, so no unpacking is needed.
            '';

            installPhase = ''
              mkdir -p $out/bin
              cp $src $out/bin/bazel
              chmod +x $out/bin/bazel
            '';

            # Disable standard Nix patching/stripping for pre-compiled binaries
            dontStrip = true;
            dontPatchELF = true;
          };

          # Set this package as the default output, allowing the user to run `nix run .`
          default = self.packages.${system}.bazel-binary;
        }
      );
    };
}
