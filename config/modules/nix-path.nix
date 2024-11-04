{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkOption;
  inherit (lib.types) bool;

  cfg = config.setup.locales;
in
{
  options = {
    setup.nixPath = {
      enable = mkOption {
        type = bool;
        default = false;
      };
    };
  };

  config = mkIf cfg.enable {
    environment.extraInit = ''
      if [ -n "''${NIX_PATH:-}" ]; then
        export NIX_PATH="nixpkgs=${pkgs.path}:$NIX_PATH"
      else
        export NIX_PATH="nixpkgs=${pkgs.path}"
      fi
    '';
  };
}
