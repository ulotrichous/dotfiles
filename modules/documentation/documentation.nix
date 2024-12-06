{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkIf
    mkMerge
    mkOption
    optional
    ;
  inherit (lib.types) bool package;

  cfg = config.documentation;
in
{
  options = {
    documentation = {
      enable = mkOption {
        type = bool;
        default = true;
      };

      man = {
        enable = mkOption {
          type = bool;
          default = true;
        };

        package = mkOption {
          type = package;
          default = pkgs.man;
        };
      };

      info = {
        enable = mkOption {
          type = bool;
          default = true;
        };
      };

      doc = {
        enable = mkOption {
          type = bool;
          default = true;
        };
      };

      dev = {
        enable = mkOption {
          type = bool;
          default = false;
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.man.enable {
      environment.packages = [ cfg.man.package ];
      environment.extraOutputsToInstall = [ "man" ] ++ optional cfg.dev.enable "devman";
    })

    (mkIf cfg.info.enable {
      environment.packages = [ pkgs.texinfoInteractive ];
      environment.extraOutputsToInstall = [ "info" ] ++ optional cfg.dev.enable "devinfo";
      environment.extraSetup = ''
        if [ -w "$out/share/info" ]; then
          shopt -s nullglob
          for i in "$out/share/info/"*.info "$out/share/info/"*.info.gz; do
            "${pkgs.buildPackages.texinfo}/bin/install-info" "$i" "$out/share/info/dir"
          done
        fi
      '';
    })

    (mkIf cfg.doc.enable {
      environment.extraOutputsToInstall = [ "doc" ] ++ optional cfg.dev.enable "devdoc";
    })
  ]);
}
