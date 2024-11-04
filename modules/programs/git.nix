{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkOption;
  inherit (lib.types) bool package;

  cfg = config.programs.git;

  settingsFormat = pkgs.formats.gitIni { };

  gitConfig = settingsFormat.generate "git-config" cfg.settings;
in
{
  options = {
    programs.git = {
      enable = mkOption {
        type = bool;
        default = false;
      };

      package = mkOption {
        type = package;
        default = pkgs.git;
      };

      settings = mkOption {
        type = settingsFormat.type;
        default = { };
      };
    };
  };

  config = mkIf cfg.enable {
    environment.packages = [ cfg.package ];

    environment.variables = {
      GIT_CONFIG_GLOBAL = gitConfig;
    };
  };
}
