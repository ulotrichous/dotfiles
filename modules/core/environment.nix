{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    attrValues
    concatMapStringsSep
    concatStringsSep
    escapeShellArgs
    filter
    isList
    mapAttrs
    mapAttrsToList
    mkDefault
    mkDerivedConfig
    mkIf
    mkOption
    optionalString
    replaceStrings
    removePrefix
    ;
  inherit (lib.types)
    attrsOf
    bool
    either
    float
    lines
    listOf
    int
    nullOr
    oneOf
    package
    path
    str
    submodule
    ;

  cfg = config.environment;

  etcType = attrsOf (
    submodule (
      {
        config,
        name,
        options,
        ...
      }:

      {
        options = {
          enable = mkOption {
            type = bool;
            default = true;
          };

          target = mkOption {
            type = str;
          };

          text = mkOption {
            type = nullOr lines;
            default = null;
          };

          source = mkOption {
            type = path;
          };
        };

        config = {
          target = mkDefault name;
          source = mkIf (config.text != null) (
            let
              name' = replaceStrings [ "/" ] [ "." ] (removePrefix "." name);
            in
            mkDerivedConfig options.text (pkgs.writeText name')
          );
        };
      }
    )
  );

  etc = pkgs.runCommandLocal "home-environment-etc" { } ''
    set -euo pipefail

    function make_entry() {
      local src="$1"
      local target="$2"

      if [[ "$src" = *'*'* ]]; then
        # If the source name contains '*', perform globbing.
        mkdir -p "$out/etc/$target"
        for f in $src; do
          ln -s "$f" "$out/etc/$target"
        done
      else
        mkdir -p "$out/etc/$(dirname "$target")"
        if [[ ! -e "$out/etc/$target" ]]; then
          ln -s "$src" "$out/etc/$target"
        else
          echo "duplicate entry $target -> $src"
        fi
      fi
    }

    mkdir -p "$out"
    ${concatMapStringsSep "\n" (
      entry:
      escapeShellArgs [
        "make_entry"
        # Force local source paths to be added to the store
        "${entry.source}"
        entry.target
      ]
    ) (filter (f: f.enable) (attrValues config.environment.etc))}
  '';

  variablesType = attrsOf (oneOf [
    (listOf (oneOf [
      float
      int
      str
    ]))
    float
    int
    path
    str
  ]);

  exportedEnvVars = concatStringsSep "\n" (
    mapAttrsToList (name: value: ''export ${name}="${value}"'') cfg.variables
  );
in
{
  options = {
    environment = {
      packages = mkOption {
        type = listOf package;
        default = { };
      };

      pathsToLink = mkOption {
        type = listOf str;
        default = [ ];
      };

      extraOutputsToInstall = mkOption {
        type = listOf str;
        default = [ ];
      };

      extraSetup = mkOption {
        type = lines;
        default = "";
      };

      etc = mkOption {
        type = etcType;
        default = { };
      };

      variables = mkOption {
        type = variablesType;
        default = { };
        apply = mapAttrs (
          name: value: if isList value then concatMapStringsSep ":" toString value else toString value
        );
      };

      extraInit = mkOption {
        type = lines;
        default = "";
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

      shellAliases = mkOption {
        type = attrsOf (nullOr (either str path));
        default = { };
      };

      homeBinInPath = mkOption {
        type = bool;
        default = false;
      };

      localBinInPath = mkOption {
        type = bool;
        default = false;
      };
    };
  };

  config = {
    environment.pathsToLink = [
      "/bin"
      "/etc"
      "/share"
    ];

    environment.packages = [ etc ];

    environment.shellAliases = mapAttrs (name: mkDefault) {
      ls = "ls --color=tty";
      ll = "ls -l";
      l = "ls -alh";
    };

    environment.etc.set-environment.text = ''
      export __HOME_SET_ENVIRONMENT_DONE=1

      ${exportedEnvVars}

      ${cfg.extraInit}

      ${optionalString cfg.homeBinInPath ''
        export PATH=$HOME/bin:$PATH
      ''}

      ${optionalString cfg.localBinInPath ''
        export PATH=$HOME/.local/bin:$PATH
      ''}
    '';

    build.path = pkgs.buildEnv {
      inherit (cfg) pathsToLink extraOutputsToInstall;
      name = "home-environement";
      paths = cfg.packages;
      postBuild = ''
        # Remove wrapped binaries, they shouldn't be accessible via PATH.
        find $out/bin -maxdepth 1 -name ".*-wrapped" -type l -delete

        ${cfg.extraSetup}
      '';
    };
  };
}
