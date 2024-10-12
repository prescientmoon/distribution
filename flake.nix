{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs) nodejs lib;
      in
      rec {
        packages.default = packages.distribution;
        packages.distribution = pkgs.buildNpmPackage.override { stdenv = pkgs.stdenvNoCC; } {
          name = "distribution";

          buildInputs = [
            nodejs
            pkgs.gzip
          ];

          src = lib.cleanSource ./.;
          npmDepsHash = "";

          postBuild = ''
            # Github pages requires an additional 404.html file
            cp dist/{index,404}.html

            # -k = keeps the original files in place
            # -r = recursive
            # -9 = best compression
            gzip -kr9 dist
          '';

          installPhase = ''
            mkdir $out
            cp -r dist $out/www
          '';
        };

        devShells.default = pkgs.mkShell { packages = [ nodejs ]; };
      }
    );
}
