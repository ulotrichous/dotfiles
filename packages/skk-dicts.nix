{
  stdenvNoCC,
  fetchFromGitHub,
  lib,
}:

let
  inherit (lib) listToAttrs replaceStrings;

  fetchSkkDict =
    name:
    stdenvNoCC.mkDerivation {
      pname = "skk-dict-${replaceStrings [ "." ] [ "-" ] name}";
      version = "2024-08-29";

      src = fetchFromGitHub {
        owner = "skk-dev";
        repo = "dict";
        rev = "4eb91a3bbfef70bde940668ec60f3beae291e971";
        hash = "sha256-r2KKCUP5Gm3KUrp4dFR2yHPlju2kfuXzXDqYXu6aPR0=";
        sparseCheckout = [ "SKK-JISYO.${name}" ];
      };

      buildCommand = ''
        mkdir -p $out/share/skk
        install -m 644 $src/SKK-JISYO.${name} $out/share/skk
      '';
    };
in
listToAttrs (
  map
    (name: {
      name = replaceStrings [ "." ] [ "-" ] name;
      value = fetchSkkDict name;
    })
    [
      "S"
      "M"
      "ML"
      "L"
      "L.unannotated"
      "jinmei"
      "geo"
      "station"
      "propernoun"
    ]
)
