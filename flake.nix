{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nix-index-database,
      emacs-overlay,
      ...
    }:
    let
      inherit (nixpkgs.lib) genAttrs systems;
      forEachSystem = genAttrs systems.flakeExposed;
    in
    {
      packages = forEachSystem (
        system:
        import ./default.nix {
          inherit
            nixpkgs
            system
            emacs-overlay
            ;
          nix-index-database-overlay = nix-index-database.overlays.nix-index;
        }
      );
    };
}
