{ pkgs, ... }:

let
  aspell = pkgs.aspellWithDicts (
    dicts: with dicts; [
      en
      en-science
      en-computers
    ]
  );
in
{
  environment.packages = [ aspell ];

  environment.variables = {
    ASPELL_CONF = "dict-dir ${aspell}/lib/aspell";
  };
}
