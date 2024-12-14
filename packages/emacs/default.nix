{
  emacs,
  emacsPackagesFor,
  runCommand,
  plantuml,
  skkDicts
}:

let
  elpaPackages =
    epkgs: with epkgs.elpaPackages; [
      auctex
      avy
      beacon
      cape
      consult
      corfu
      ellama
      embark
      embark-consult
      ement
      jinx
      marginalia
      orderless
      org-modern
      tempel
      valign
      vertico
      vundo
    ];

  nongnuPackages =
    epkgs: with epkgs.nongnuPackages; [
      eat
      exec-path-from-shell
      git-modes
      magit
      markdown-mode
      rust-mode
      yaml-mode
    ];

  nongnuDevelPackages =
    epkgs: with epkgs.nongnuDevelPackages; [
      treesit-fold
    ];

  melpaPackages =
    epkgs: with epkgs.melpaPackages; [
      cmake-mode
      ddskk
      dimmer
      envrc
      haskell-mode
      nix-mode
      nix-ts-mode
      nov
      olivetti
      org-appear
      org-roam
      pdf-tools
      web-mode
      wgrep
      whitespace-cleanup-mode
    ];

  manualPackages =
    epkgs: with epkgs.manualPackages; [
      treesit-grammars.with-all-grammars
    ];

  default = runCommand "emacs-default" { } ''
    install -m 644 "${./config.org}" config.org

    "${emacs}/bin/emacs" --batch \
      --eval "(require 'ob-tangle)" \
      --eval "(org-babel-tangle-file \"config.org\")"

    mkdir -p "$out/share/emacs/site-lisp"
    substitute default.el "$out/share/emacs/site-lisp/default.el" \
      --subst-var-by templates "${./templates}" \
      --subst-var-by plantuml "${plantuml}" \
      --subst-var-by skkDict "${skkDicts.L}"
  '';

  packages =
    epkgs:
    [ default ]
    ++ builtins.concatMap (f: f epkgs) [
      elpaPackages
      nongnuPackages
      nongnuDevelPackages
      melpaPackages
      manualPackages
    ];

  emacsWithPackages = (emacsPackagesFor emacs).withPackages packages;
in
emacsWithPackages
