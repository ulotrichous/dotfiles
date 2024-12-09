{ pkgs, ... }:

let
  aspell = pkgs.aspellWithDicts (
    dicts: with dicts; [
      en
    ]
  );
in
{
  environment.packages = [ aspell ];

  environment.variables = {
    ASPELL_CONF = "dict-dir ${aspell}/lib/aspell";
  };
}
