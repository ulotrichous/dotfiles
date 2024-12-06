let
  sources = import ./sources.nix;
  makeNixIndexDatabaseOverlay = import ./utils/make-nix-index-database-overlay.nix;
in
{
  nixpkgs ? sources.nixpkgs,
  system ? null,
  emacs-overlay ? sources.emacs-overlay,
  nix-index-database-overlay ? makeNixIndexDatabaseOverlay {
    src = sources.nix-index-database;
  },
}:
let
  pkgs = import nixpkgs (
    {
      config.allowUnfree = true;
      overlays = [
        (import "${emacs-overlay}/overlays/package.nix")
        (import ./overlays/emacs-with-packages.nix)
        (import ./overlays/gitignore.nix)
        nix-index-database-overlay
      ];
    }
    // (if isNull system then { } else { inherit system; })
  );

  lib = pkgs.lib.extend (self: super: import ./lib { nixpkgs = self; });

  makeProfile =
    config:
    let
      eval = lib.evalConfig {
        modules = [
          {
            nixpkgs.pkgs = pkgs;
            imports = [ config ];
          }
        ];
      };
    in
    eval.config.build.environment;
in
lib.mapAttrs (_: config: makeProfile config) (import ./config)
