{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
          t    = pkgs.lib.trivial;
          hl   = pkgs.haskell.lib;

          hpkgs = pkgs.haskell.packages.ghc942;
          # hpkgs = pkgs.haskell.packages.ghc924;
          # hpkgs = pkgs.haskell.packages.ghc902;
          # hpkgs = pkgs.haskell.packages.ghc8107;

          nativeDeps = [
            pkgs.gmp
            pkgs.libffi
            pkgs.zlib
          ];

      in {
        devShell = pkgs.mkShell {

          buildInputs = nativeDeps;

          nativeBuildInputs = [
            pkgs.gdb

            hpkgs.ghc

            pkgs.haskell.packages.ghc924.cabal-install
          ] ++ map (x: if builtins.hasAttr "dev" x then x.dev else x) nativeDeps;

          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath nativeDeps;
        };
      });
}
