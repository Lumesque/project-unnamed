{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs = { self, nixpkgs, zig-overlay, flake-utils }:
  flake-utils.lib.eachDefaultSystem (system:
  let
    overlays = [ zig-overlay.overlays.default ];
    pkgs = nixpkgs.legacyPackages.${system}.appendOverlays overlays;
    doxypypy = (import ./deps/doxypypy.nix {inherit pkgs;}).default;
    python-packages = [(pkgs.python312.withPackages (pp: [
      pp.ipython
      pp.pytest
    ]))];
    dev-pkgs = [
      pkgs.zigpkgs."0.13.0"
      pkgs.gcc
      pkgs.doxygen
      doxypypy
    ];
  in
  {

    packages.default = pkgs.symlinkJoin {
      name = "nix shell dev env";
      paths = dev-pkgs ++ python-packages;
    };

    devShells.default = pkgs.mkShell {
      packages = dev-pkgs ++ python-packages;
    };
  });
}
