{ pkgs, ... }:

{
  environment.extraInit = ''
    if [ -n "''${NIX_PATH:-}" ]; then
      export NIX_PATH="nixpkgs=${pkgs.path}:$NIX_PATH"
    else
      export NIX_PATH="nixpkgs=${pkgs.path}"
    fi
  '';
}
