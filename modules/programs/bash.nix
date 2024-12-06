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
    if [ -n "$__NIX_ETC_PROFILE_SOURCED" ]; then
      return
    fi
    __NIX_ETC_PROFILE_SOURCED=1

    # Prevent this file from being sourced by interactive non-login child shells.
    export __NIX_ETC_PROFILE_DONE=1

    ${cfg.shellInit}
    ${cfg.loginShellInit}

    if [ -n "''${BASH_VERSION:-}" ]; then
      . "@out@/etc/bashrc"
    fi
  '';

  etcBashrc = ''
    # Only execute this file once per shell.
    if [ -n "$__NIX_ETC_BASHRC_SOURCED" ]; then
      return
    fi
    __NIX_ETC_BASHRC_SOURCED=1

    if [ -z "$__NIX_ETC_PROFILE_DONE" ]; then
      . "@out@/etc/profile"
    fi

    if [ -n "$PS1" ]; then
      ${cfg.interactiveShellInit}
    fi
  '';

  bashInit = pkgs.runCommandLocal "bash-initialisation" { } ''
    mkdir -p "$out/etc"

    cat << 'EOF' > "$out/etc/profile"
    ${etcProfile}
    EOF

    cat << 'EOF' > "$out/etc/bashrc"
    ${etcBashrc}
    EOF

    substituteInPlace "$out/etc/profile" "$out/etc/bashrc" --subst-var out
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
    environment.packages = [ bashInit ];

    programs.bash = {
      shellAliases = mapAttrs (name: mkDefault) cfge.shellAliases;

      shellInit = ''
        if [ -z "$__NIX_ETC_SET_ENVIRONMENT_DONE" ]; then
          . "${config.build.setEnvironment}"
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
  };
}
