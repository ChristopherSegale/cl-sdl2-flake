{
  description = "Flake for packaging the cl-sdl2 library.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    cl-nix-lite.url = "github:hraban/cl-nix-lite";
    flake-utils.url = "github:numtide/flake-utils";
    common-lisp-sdl2 = {
      url = "github:lispgames/cl-sdl2";
      flake = false;
    };
    t-chan = {
      url = "github:rpav/trivial-channels";
      flake = false;
    };
    clAutoWrap.url = "github:ChristopherSegale/cl-autowrap-flake";
  };

  outputs = inputs @ { self, nixpkgs, cl-nix-lite, flake-utils, common-lisp-sdl2, t-chan, clAutoWrap }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system}.extend cl-nix-lite.overlays.default;
      inherit (pkgs.lispPackagesLite) lispDerivation bordeaux-threads trivial-timeout alexandria
                                      cl-ppcre trivial-features;
      cl-autowrap = clAutoWrap.packages.${system}.default;
      inherit (clAutoWrap.packages.${system}) cl-plus-c;
      trivial-channels = lispDerivation {
        src = t-chan;
        lispDependencies = [ bordeaux-threads trivial-timeout ];
        lispSystem = "trivial-channels";
      };
    in {
      packages = {
        default = lispDerivation {
          src = common-lisp-sdl2;
          buildInputs = with pkgs; [
            SDL2
            pkg-config
          ];
          lispDependencies = [
            alexandria
            cl-autowrap
            cl-plus-c
            cl-ppcre
            trivial-channels
            trivial-features
          ];
          lispSystem = "sdl2";
        };
      };
    });
}
