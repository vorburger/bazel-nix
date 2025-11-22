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
          version = "8.4.2";
          platforms = {
            "x86_64-linux" = {
              systemName = "linux-x86_64";
              sha256 = "sha256-TcjpnfqALiUtrBdtCCAf0VxUKueMRIyKiZdLbzh8KCw=";
            };
            "x86_64-darwin" = {
              systemName = "darwin-x86_64";
              sha256 = "sha256-znM0YnTDefd4gNuL2LnIVpiF/lbxk4YXN2CUnakHjfA=";
            };
            # TODO aarch64-linux
            # TODO aarch64-darwin
          };
          platform = platforms.${system} or (builtins.throw "Unsupported system: ''${system}");
        in
        {
          bazel-binary = pkgs.stdenv.mkDerivation {
            pname = "bazel";
            inherit version;

            src = pkgs.fetchurl {
              url = "https://github.com/bazelbuild/bazel/releases/download/${version}/bazel-${version}-${platform.systemName}";
              sha256 = platform.sha256;
            };

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

            meta = with lib; {
              description = "Bazel binary";
              homepage = "https://github.com/bazelbuild/bazel";
              license = licenses.asl20;
              platforms = builtins.attrNames platforms;
              maintainers = with maintainers; [ vorburger ];
            };
          };

          # Set this package as the default output, allowing the user to run `nix run .`
          default = self.packages.${system}.bazel-binary;
        }
      );
    };
}
