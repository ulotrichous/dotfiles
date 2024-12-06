{ src }:

let
  generated = import "${src}/generated.nix";
in
self: super:
let
  nix-index-database =
    (self.fetchurl {
      url = generated.url + self.stdenv.system;
      hash = generated.hashes.${self.stdenv.system};
    }).overrideAttrs
      {
        __structuredAttrs = true;
        unsafeDiscardReferences.out = true;
      };
in
{
  inherit nix-index-database;
  nix-index-with-db = self.callPackage "${src}/nix-index-wrapper.nix" {
    inherit nix-index-database;
  };
  comma-with-db = self.callPackage "${src}/comma-wrapper.nix" {
    inherit nix-index-database;
  };
}
