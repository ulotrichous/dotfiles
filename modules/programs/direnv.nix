{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    boolToString
    mkIf
    mkOption
    optionalString
    ;
  inherit (lib.types) bool lines package;

  cfg = config.programs.direnv;

  direnvrc = pkgs.writeTextFile {
    name = "direnvrc";
    destination = "/etc/direnv/direnvrc";
    text = ''
      ${optionalString cfg.nix-direnv.enable ''
        . "${cfg.nix-direnv.package}/share/nix-direnv/direnvrc"
      ''}

      ${cfg.direnvrcExtra}
    '';
  };
in
{
  options = {
    programs.direnv = {
      enable = mkOption {
        type = bool;
        default = false;
      };

      package = mkOption {
        type = package;
        default = pkgs.direnv;
      };

      enableBashIntegration = mkOption {
        type = bool;
        default = true;
      };

      direnvrcExtra = mkOption {
        type = lines;
        default = "";
      };

      silent = mkOption {
        type = bool;
        default = true;
      };

      loadInNixShell = mkOption {
        type = bool;
        default = true;
      };

      nix-direnv = {
        enable = mkOption {
          type = bool;
          default = true;
        };

        package = mkOption {
          type = package;
          default = pkgs.nix-direnv;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    environment.packages = [ cfg.package ];

    environment.variables = {
      DIRENV_CONFIG = "${direnvrc}/etc/direnv";
      DIRENV_LOG_FORMAT = mkIf cfg.silent "";
    };

    programs.bash.interactiveShellInit = mkIf cfg.enableBashIntegration ''
      if ${boolToString cfg.loadInNixShell} || [ -z "$IN_NIX_SHELL$NIX_GCROOT$(printenv PATH | grep '/nix/store')" ]; then
        eval "$("${cfg.package}/bin/direnv" hook bash)"
      fi
    '';
  };
}
