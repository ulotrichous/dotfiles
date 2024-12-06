{ lib, ... }:

let
  inherit (lib) mkOption;
  inherit (lib.types)
    lazyAttrsOf
    submoduleWith
    uniq
    unspecified
    ;
in
{
  options = {
    build = mkOption {
      type = submoduleWith {
        modules = [ { freeformType = lazyAttrsOf (uniq unspecified); } ];
      };
      default = { };
    };
  };
}
