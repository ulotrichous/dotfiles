{
  pkgs ? import <nixpkgs> { },
}:

let
  inherit (pkgs) callPackage;
in
rec {
  emacs-with-packages = callPackage ./emacs { inherit skkDicts; };
  gitignore = callPackage ./gitignore.nix { };
  skkDicts = callPackage ./skk-dicts.nix { };
}
