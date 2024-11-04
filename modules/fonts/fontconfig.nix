{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    concatStringsSep
    mkIf
    mkOption
    optionalString
    ;
  inherit (lib.types) bool listOf str;

  cfg = config.fonts.fontconfig;

  cacheConf =
    let
      makeCache =
        fontconfig:
        pkgs.makeFontsCache {
          inherit fontconfig;
          fontDirectories = config.fonts.packages;
        };
      cache = makeCache pkgs.fontconfig;
      cache32 = makeCache pkgs.pkgsi686Linux.fontconfig;
    in
    pkgs.writeText "fc-00-cache.conf" ''
      <?xml version="1.0"?>
      <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
      <fontconfig>
        <!-- Font Directories -->
        ${concatStringsSep "\n" (map (font: "<dir>${font}</dir>") config.fonts.packages)}

        ${
          optionalString (pkgs.stdenv.hostPlatform == pkgs.stdenv.buildPlatform) ''
            <!-- Pre-generated Font Caches -->
            <cachedir>${cache}</cachedir>

            ${optionalString (pkgs.stdenv.hostPlatform.isx86_64 && cfg.cache32Bit) ''
              <cachedir>${cache32}</cachedir>
            ''}
          ''
        }
      </fontconfig>
    '';

  defaultFontsConf =
    let
      genDefault =
        fonts: name:
        optionalString (fonts != [ ]) ''
          <alias binding="same">
            <family>${name}</family>
            <prefer>
            ${concatStringsSep "\n" (map (font: ''<family>${font}</family>'') fonts)}
            </prefer>
          </alias>
        '';
    in
    pkgs.writeText "fc-52-default-fonts.conf" ''
      <?xml version='1.0'?>
      <!DOCTYPE fontconfig SYSTEM 'urn:fontconfig:fonts.dtd'>
      <fontconfig>
        ${genDefault cfg.defaultFonts.sansSerif "sans-serif"}
        ${genDefault cfg.defaultFonts.serif "serif"}
        ${genDefault cfg.defaultFonts.monospace "monospace"}
        ${genDefault cfg.defaultFonts.emoji "emoji"}
      </fontconfig>
    '';

  fontconfigConfig = pkgs.runCommandLocal "fontconfig-config" { } ''
    mkdir -p "$out/etc/fonts/conf.d"

    substitute \
      "${pkgs.fontconfig.out}/etc/fonts/fonts.conf" \
      "$out/etc/fonts/fonts.conf" \
      --replace-fail "/etc/fonts/conf.d" "$out/etc/fonts/conf.d"

    ln -s "${cacheConf}" "$out/etc/fonts/conf.d/00-cache.conf"

    ln -s "${defaultFontsConf}" "$out/etc/fonts/conf.d/52-default-fonts.conf"
  '';
in
{
  options = {
    fonts.fontconfig = {
      enable = mkOption {
        type = bool;
        default = false;
      };

      defaultFonts = {
        sansSerif = mkOption {
          type = listOf str;
          default = [ "DejaVu Sans" ];
        };

        serif = mkOption {
          type = listOf str;
          default = [ "DejaVu Serif" ];
        };

        monospace = mkOption {
          type = listOf str;
          default = [ "DejaVu Sans Mono" ];
        };

        emoji = mkOption {
          type = listOf str;
          default = [ ];
        };
      };

      cache32Bit = mkOption {
        type = bool;
        default = false;
      };
    };
  };

  config = mkIf cfg.enable {
    environment.packages = [ pkgs.fontconfig ];

    environment.variables = {
      FONTCONFIG_FILE = "${fontconfigConfig}/etc/fonts/fonts.conf";
    };
  };
}
