let
  withModules = path: {
    imports = import ./modules/module-list.nix ++ [ path ];
  };
in
{
  shaun = withModules ./shaun.nix;
  timmy = withModules ./timmy.nix;
}
