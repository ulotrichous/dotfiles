{
  pkgs ? import <nixpkgs> { },
}:

let
  inherit (pkgs) callPackage;
in
{
  emacs-with-packages = callPackage ./emacs { };
  gitignore = callPackage ./gitignore.nix { };
}
