{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkOption;
  inherit (lib.types) bool listOf path;

  cfg = config.fonts;
in
{
  options = {
    fonts = {
      packages = mkOption {
        type = listOf path;
        default = [ ];
      };

      enableDefaultPackages = mkOption {
        type = bool;
        default = false;
      };
    };
  };

  config = {
    fonts.packages = mkIf cfg.enableDefaultPackages (
      with pkgs;
      [
        dejavu_fonts
        freefont_ttf
        gyre-fonts
        liberation_ttf
        unifont
        noto-fonts-color-emoji
      ]
    );
  };
}
