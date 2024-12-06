let
  inherit (builtins)
    attrNames
    concatMap
    fromJSON
    hasAttr
    listToAttrs
    readFile
    ;

  lock = fromJSON (readFile ./flake.lock);

  fetchGitHub =
    locked:
    let
      inherit (locked)
        narHash
        owner
        repo
        rev
        ;
    in
    fetchTarball {
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
      sha256 = narHash;
    };
in
listToAttrs (
  concatMap (
    name:
    let
      node = lock.nodes.${name};
    in
    if hasAttr "locked" node && node.locked.type == "github" then
      [
        {
          inherit name;
          value = fetchGitHub node.locked;
        }
      ]
    else
      [ ]
  ) (attrNames lock.nodes)
)
