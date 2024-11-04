{ stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation {
  name = "gitignore";

  src = fetchFromGitHub {
    owner = "github";
    repo = "gitignore";
    rev = "8779ee73af62c669e7ca371aaab8399d87127693";
    hash = "sha256-cuTgVjLeZQR7qLXI2AYNOLX+hT81INqCRX6qclc1s3g=";
  };

  buildCommand = ''
    cat $src/Global/Emacs.gitignore >> $out
    cat $src/Global/Linux.gitignore >> $out
    cat $src/Global/Vim.gitignore >> $out
    cat $src/Global/Windows.gitignore >> $out

    echo >> $out

    cat << EOF >> $out
    # Direnv
    .direnv/
    EOF
  '';
}
