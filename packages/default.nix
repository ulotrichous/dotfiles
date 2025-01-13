{
  pkgs ? import <nixpkgs> { },
}:

let
  inherit (pkgs) callPackage;
in
rec {
  emacs-with-packages = callPackage ./emacs { inherit skkDicts; };
  firefox-with-custom-wrapper = callPackage ./firefox.nix { };
  gitignore = callPackage ./gitignore.nix { };
  skkDicts = callPackage ./skk-dicts.nix { };
}
