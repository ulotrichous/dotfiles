{
  melpaBuild,
  fetchFromGitea,
}:

melpaBuild {
  pname = "typst-ts-mode";
  # `version` must start with a number
  version = "0-unstable-2024-12-18";
  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "meow_king";
    repo = "typst-ts-mode";
    rev = "1367003e2ad55a2f6f9e43178584683028ab56e9";
    hash = "sha256-0RAJ/Td3G7FDvzf7t8csNs/uc07WUPGvMo8ako5iyl0=";
  };
}
