let
  sources = import ./sources.nix;
in
{
  pkgs ? import sources.nixpkgs { },
}:

pkgs.mkShell {
  packages = with pkgs; [
    just
    nixd
    nixfmt-rfc-style
  ];
}
