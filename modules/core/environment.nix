{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    concatMapStringsSep
    concatStringsSep
    isList
    mapAttrs
    mapAttrsToList
    mkDefault
    mkOption
    ;
  inherit (lib.types)
    attrsOf
    either
    float
    int
    lines
    listOf
    nullOr
    oneOf
    package
    path
    str
    ;

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

  cfg = config.environment;

  linkSetEnvironment = pkgs.runCommandLocal "set-environment" { } ''
    mkdir -p "$out/etc"
    ln -s ${config.build.setEnvironment} "$out/etc/set-environment"
  '';
in
{
  options = {
    environment = {
      packages = mkOption {
        type = listOf package;
        default = { };
      };

      extraOutputsToInstall = mkOption {
        type = listOf str;
        default = [ ];
      };

      extraSetup = mkOption {
        type = lines;
        default = "";
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
    };
  };

  config = {
    environment.packages = [ linkSetEnvironment ];

    environment.shellAliases = mapAttrs (name: mkDefault) {
      ls = "ls --color=tty";
      ll = "ls -l";
      l = "ls -alh";
    };

    build.environment = pkgs.buildEnv {
      inherit (cfg) extraOutputsToInstall;

      name = "environment";
      paths = cfg.packages;

      postBuild = ''
        # Remove wrapped binaries, they shouldn't be accessible via PATH.
        find $out/bin -maxdepth 1 -name ".*-wrapped" -type l -delete

        ${cfg.extraSetup}
      '';
    };

    build.setEnvironment = pkgs.writeText "set-environment" ''
      export __NIX_ETC_SET_ENVIRONMENT_DONE=1

      ${exportedEnvVars}

      ${cfg.extraInit}
    '';
  };
}
