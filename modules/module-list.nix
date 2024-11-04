let
  core = import ./core/module-list.nix;
in
core
++ [
  ./documentation/documentation.nix
  ./fonts/fontconfig.nix
  ./fonts/packages.nix
  ./programs/bash.nix
  ./programs/direnv.nix
  ./programs/nix-index.nix
  ./programs/git.nix
]
