{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    concatStringsSep
    escapeShellArg
    filterAttrs
    mapAttrs
    mapAttrsToList
    mkDefault
    mkIf
    mkOption
    ;
  inherit (lib.types)
    attrsOf
    bool
    either
    lines
    nullOr
    package
    path
    str
    ;

  cfg = config.programs.bash;
  cfge = config.environment;

  bashAliases = concatStringsSep "\n" (
    mapAttrsToList (name: value: "alias -- ${name}=${escapeShellArg value}") (
      filterAttrs (name: value: value != null) cfg.shellAliases
    )
  );

  etcProfile = ''
    # Only execute this file once per shell.
    if [ -n "$__HOME_PROFILE_SOURCED" ]; then
      return
    fi
    __HOME_PROFILE_SOURCED=1

    # Prevent this file from being sourced by interactive non-login child shells.
    export __HOME_PROFILE_DONE=1

    ${cfg.shellInit}
    ${cfg.loginShellInit}

    if [ -n "''${BASH_VERSION:-}" ]; then
      . "@out@/bashrc"
    fi
  '';

  etcBashrc = ''
    # Only execute this file once per shell.
    if [ -n "$__HOME_BASHRC_SOURCED" ]; then
      return
    fi
    __HOME_BASHRC_SOURCED=1

    if [ -z "$__HOME_PROFILE_DONE" ]; then
      . "@out@/profile"
    fi

    if [ -n "$PS1" ]; then
      ${cfg.interactiveShellInit}
    fi
  '';

  etc = pkgs.runCommandLocal "etc" { } ''
    mkdir -p "$out"

    cat << 'EOF' > "$out/profile"
    ${etcProfile}
    EOF

    cat << 'EOF' > "$out/bashrc"
    ${etcBashrc}
    EOF

    substituteInPlace "$out/profile" "$out/bashrc" --subst-var out
  '';
in
{
  options = {
    programs.bash = {
      enable = mkOption {
        type = bool;
        default = true;
      };

      shellAliases = mkOption {
        type = attrsOf (nullOr (either str path));
        default = { };
      };

      shellInit = mkOption {
        type = lines;
        default = "";
      };

      loginShellInit = mkOption {
        type = lines;
        default = "";
      };

      interactiveShellInit = mkOption {
        type = lines;
        default = "";
      };

      promptInit = mkOption {
        type = lines;
        default = "";
      };

      promptPluginInit = mkOption {
        type = lines;
        default = "";
        internal = true;
      };

      completion = {
        enable = mkOption {
          type = bool;
          default = true;
        };

        package = mkOption {
          type = package;
          default = pkgs.bash-completion;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    programs.bash = {
      shellAliases = mapAttrs (name: mkDefault) cfge.shellAliases;

      shellInit = ''
        if [ -z "$__HOME_SET_ENVIRONMENT_DONE" ]; then
          . "${config.environment.etc.set-environment.source}"
        fi

        ${cfge.shellInit}
      '';

      loginShellInit = cfge.loginShellInit;

      interactiveShellInit = ''
        # Check the window size after every command.
        shopt -s checkwinsize

        # Disable hashing (i.e. caching) of command lookups.
        set +h

        ${cfg.promptInit}
        ${cfg.promptPluginInit}
        ${bashAliases}

        ${cfge.interactiveShellInit}
      '';

      promptPluginInit = mkIf cfg.completion.enable ''
        if shopt -q progcomp &>/dev/null; then
          . ${cfg.completion.package}/etc/profile.d/bash_completion.sh
        fi
      '';
    };

    environment.etc.profile.source = "${etc}/profile";

    environment.etc.bashrc.source = "${etc}/bashrc";
  };
}
