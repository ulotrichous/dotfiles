{ pkgs, ... }:

{
  environment.variables = {
    # https://nixos.org/manual/nixpkgs/stable/#locales
    LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
  };
}
