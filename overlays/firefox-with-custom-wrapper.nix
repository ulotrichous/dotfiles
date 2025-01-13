self: super:
let
  packages = import ../packages { pkgs = self; };
in
{
  inherit (packages) firefox-with-custom-wrapper;
}
