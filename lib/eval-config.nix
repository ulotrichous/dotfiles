{ nixpkgs }:

let
  inherit (nixpkgs) evalModules;
in
{
  modules ? [ ],
  specialArgs ? { },
  minimal ? false,
}:
let
  baseModules =
    if minimal then import ../modules/core/module-list.nix else import ../modules/module-list.nix;
in
evalModules {
  modules = baseModules ++ modules;
  specialArgs = {
    modulesPath = builtins.toString ../modules;
  } // specialArgs;
}
