{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkOption;
  inherit (lib.types) bool package;

  cfg = config.programs.nix-index;
in
{
  options = {
    programs.nix-index = {
      enable = mkOption {
        type = bool;
        default = false;
      };

      package = mkOption {
        type = package;
        default = pkgs.nix-index;
      };

      enableBashIntegration = mkOption {
        type = bool;
        default = true;
      };
    };
  };

  config = mkIf cfg.enable {
    environment.packages = [ cfg.package ];

    programs.bash.interactiveShellInit = mkIf cfg.enableBashIntegration ''
      . "${cfg.package}/etc/profile.d/command-not-found.sh"
    '';
  };
}
