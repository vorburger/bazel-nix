{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      lib = nixpkgs.lib;
      systems = [ "x86_64-linux" "x86_64-darwin" ];
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

            src = if pkgs.stdenv.isLinux then pkgs.fetchurl {
              url = "https://github.com/bazelbuild/bazel/releases/download/8.4.2/bazel-8.4.2-linux-x86_64";
              sha256 = "sha256-TcjpnfqALiUtrBdtCCAf0VxUKueMRIyKiZdLbzh8KCw=";
            } else if pkgs.stdenv.isDarwin then pkgs.fetchurl {
              url = "https://github.com/bazelbuild/bazel/releases/download/8.4.2/bazel-8.4.2-darwin-x86_64";
              sha256 = "sha256-znM0YnTDefd4gNuL2LnIVpiF/lbxk4YXN2CUnakHjfA=";
            } else (
              builtins.throw "Unsupported system: ${system}"
            );

            buildInputs = lib.optionals pkgs.stdenv.isLinux [
              pkgs.stdenv.cc.cc
            ];

            nativeBuildInputs = lib.optionals pkgs.stdenv.isLinux [
              pkgs.autoPatchelfHook
            ];

            installPhase = ''
              runHook preInstall
              mkdir -p $out/bin
              cp $src $out/bin/bazel
              chmod +x $out/bin/bazel
              runHook postInstall
            '';

            postFixup = ''
              # $out/bin/bazel --version
            '';

            dontBuild = true;
            dontUnpack = true;
            dontStrip = true;
            dontPatchELF = !pkgs.stdenv.isLinux;
          };

          # Set this package as the default output, allowing the user to run `nix run .`
          default = self.packages.${system}.bazel-binary;
        }
      );
    };
}
