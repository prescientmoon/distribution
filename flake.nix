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
        inherit (pkgs) lib;
      in
      rec {
        packages.default = packages.distribution;
        packages.distribution = pkgs.buildNpmPackage.override { stdenv = pkgs.stdenvNoCC; } {
          name = "distribution";

          buildInputs = [ pkgs.nodejs ];

          src = lib.cleanSource ./.;
          npmDepsHash = "sha256-OiYiLcp9bmFyBK38Xh6nK1XGgILUjcVtD+vxb41i/wU=";

          postBuild = ''
            cp dist/{index,404}.html # Github pages requires an additional 404.html file
          '';

          installPhase = ''
            mkdir $out
            cp -r dist $out/www
          '';
        };
      }
    );
}
