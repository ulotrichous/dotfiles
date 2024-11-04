{ lib, ... }:

let
  inherit (lib) mkOption;
  inherit (lib.types) package;
in
{
  options = {
    build = {
      path = mkOption {
        type = package;
        readOnly = true;
      };
    };
  };
}
