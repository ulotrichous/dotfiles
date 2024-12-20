{
  emacs,
  emacsPackagesFor,
  runCommandLocal,
  skkDicts,
}:

let
  overrides = self: super: {
    default = runCommandLocal "emacs-default" { } ''
      cp ${./config.org} config.org

      ${emacs}/bin/emacs --batch \
        --eval "(require 'ob-tangle)" \
        --eval "(org-babel-tangle-file \"config.org\" \"default.el\")"

      mkdir -p $out/share/emacs/site-lisp

      install -m 644 default.el $out/share/emacs/site-lisp
    '';

    tempel = super.tempel.overrideAttrs (attrs: {
      postPatch =
        attrs.postPatch or ""
        + ''
          substituteInPlace tempel.el \
            --replace '(expand-file-name "templates" user-emacs-directory)' \
                      '"${./templates}/*.eld"'
        '';
    });

    ddskk = super.ddskk.overrideAttrs (attrs: {
      postPatch =
        attrs.postPatch or ""
        + ''
          substituteInPlace skk-vars.el \
            --replace 'skk-large-jisyo nil' \
                      'skk-large-jisyo "${skkDicts.L}/share/skk/SKK-JISYO.L"'
        '';
    });

    typst-ts-mode = self.callPackage ./typst-ts-mode.nix { };
  };

  packages =
    epkgs: with epkgs; [
      auctex
      avy
      beacon
      cape
      cmake-mode
      consult
      corfu
      ddskk
      default
      dired-subtree
      eat
      ellama
      embark
      embark-consult
      ement
      envrc
      exec-path-from-shell
      git-modes
      haskell-mode
      jinx
      magit
      marginalia
      markdown-mode
      nix-mode
      nix-ts-mode
      nov
      olivetti
      orderless
      org-appear
      org-contacts
      org-modern
      org-roam
      pdf-tools
      rust-mode
      tempel
      treesit-fold
      treesit-grammars.with-all-grammars
      typst-ts-mode
      valign
      vertico
      vundo
      web-mode
      wgrep
      whitespace-cleanup-mode
      yaml-mode
    ];

  emacsWithPackages = ((emacsPackagesFor emacs).overrideScope overrides).withPackages packages;
in
emacsWithPackages
