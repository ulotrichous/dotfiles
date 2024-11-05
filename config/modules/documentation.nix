{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkOption;
  inherit (lib.types) bool;

  cfg = config.setup.documentation;
in
{
  options = {
    setup.documentation = {
      enable = mkOption {
        type = bool;
        default = false;
      };
    };
  };

  config = mkIf cfg.enable {
    documentation.enable = true;

    environment.extraInit = ''
      if [ -n "''${MANPATH:-}" ]; then
        export MANPATH="$HOME/.nix-profile/share/man:$MANPATH"
      else
        export MANPATH="$HOME/.nix-profile/share/man:/usr/share/man"
      fi
    '';
  };
}
