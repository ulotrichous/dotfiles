{
  nixpkgs ? import <nixpkgs/lib>,
}:

let
  evalConfig = import ./eval-config.nix { inherit nixpkgs; };
in
{
  inherit evalConfig;
}
