self: super:
let
  packages = import ../packages { pkgs = self; };
in
{
  inherit (packages) emacs-with-packages;
}
