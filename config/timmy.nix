{ modulesPath, pkgs, ... }:

{
  imports = [
    "${modulesPath}/profiles/locales.nix"
    "${modulesPath}/profiles/nix-path.nix"

    ./modules/aspell.nix
    ./modules/direnv.nix
  ];

  documentation.enable = true;

  programs.bash.enable = true;

  programs.git = {
    enable = true;
    settings = {
      commit.gpgsign = true;
      core.excludesFile = "${pkgs.gitignore}";
      init.defaultBranch = "main";
      include.path = "~/.config/git/config";
    };
  };

  programs.nix-index = {
    enable = true;
    package = pkgs.nix-index-with-db;
  };

  environment.extraInit = ''
    export PATH="$HOME/.local/bin:$PATH"
    export MANPATH="$HOME/.nix-profile/share/man:/usr/share/man"
  '';

  environment.variables = {
    COLORTERM = "truecolor";
    PASSWORD_STORE_DIR = "$OneDrive/secrets/password-store";
  };

  environment.packages = with pkgs; [
    (emacs-with-packages.override {
      emacs = pkgs.emacs30;
    })
    bash-language-server
    browserpass
    comma-with-db
    curl
    fd
    findutils
    gdb
    gnupg
    helix
    jq
    pass
    pipx
    plantuml
    ripgrep
    ruff
    shellcheck
    trash-cli
    tshark
    typst
    unzip
    zip
  ];

  environment.shellAliases = {
    python = "python3";
  };

  fonts.fontconfig.enable = true;

  fonts.packages = with pkgs; [
    iosevka
    sarasa-gothic

    (iosevka-bin.override { variant = "Aile"; })
    (iosevka-bin.override { variant = "SGr-IosevkaTerm"; })
  ];
}
