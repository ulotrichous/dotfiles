{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkOption;
  inherit (lib.types) bool;

  cfg = config.setup.nix-index;
in
{
  options = {
    setup.nix-index = {
      enable = mkOption {
        type = bool;
        default = false;
      };
    };
  };

  config = mkIf cfg.enable {
    programs.nix-index = {
      enable = true;
      package = pkgs.nix-index-with-db;
    };

    environment.packages = [
      pkgs.comma-with-db
    ];
  };
}
