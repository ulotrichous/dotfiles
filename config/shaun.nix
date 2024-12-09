{ modulesPath, pkgs, ... }:

{
  imports = [
    "${modulesPath}/profiles/locales.nix"
    "${modulesPath}/profiles/nix-path.nix"
  ];

  documentation.enable = true;

  programs.bash.enable = true;

  programs.direnv = {
    enable = true;
    direnvrcExtra = ''
      layout_hatch() {
          if [[ ! -f "pyproject.toml" ]]; then
              if [[ ! -f "setup.py" ]]; then
                  local tmpdir
                  log_status "No pyproject.toml or setup.py found. Executing \`hatch new\` to create a new project."
                  PROJECT_NAME=$(basename $PWD)
                  tmpdir="$(mktemp -d)"
                  hatch new $PROJECT_NAME $tmpdir > /dev/null
                  cp -a --no-clobber $tmpdir/* . && rm -rf $tmpdir
              else
                  # I haven't yet seen a case where migrating from an existing `setup.py` works, but I'm sure there are some.
                  log_status "No pyproject.toml found. Executing \`hatch new --init\` to migrate from setuptools."
                  hatch new --init || log_error "Failed to migrate from setuptools. Please fix and run \`hatch new --init\` manually." && return 1
              fi
          fi

          HATCH_ENV=''${HATCH_ENV_ACTIVE:-default}
          # We need this to error out if the env doesn't exist in the pyproject.toml file.
          VIRTUAL_ENV=$(hatch env find $HATCH_ENV)

          if [[ ! -d $VIRTUAL_ENV ]]; then
              log_status "No virtual environment exists. Executing \`hatch env create\` to create one."
              hatch env create $HATCH_ENV
          fi

          PATH_add "$VIRTUAL_ENV/bin"
          export HATCH_ENV_ACTIVE=$HATCH_ENV  # or VENV_ACTIVE=1
          export VIRTUAL_ENV
      }
    '';
  };

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

  environment.loginShellInit = ''
    export GRIM_DEFAULT_DIR="$(xdg-user-dir PICTURES)/grim"

    # https://fcitx-im.org/wiki/Setup_Fcitx_5
    export XMODIFIERS=@im=fcitx
    export GTK_IM_MODULE=fcitx
    export QT_IM_MODULE=fcitx

    # https://wiki.debian.org/KVM
    export LIBVIRT_DEFAULT_URI='qemu:///system';
  '';

  environment.packages = with pkgs; [
    (emacs-with-packages.override {
      emacs = pkgs.emacs30;
    })
    bash-language-server
    browserpass
    comma-with-db
    curl
    fd
    ffmpeg
    findutils
    gdb
    gnugrep
    gnupg
    helix
    hunspellDicts.en_GB-ise
    hunspellDicts.en_US
    inkscape
    mpv
    nuspell
    pass-wayland
    pinentry-qt
    pipx
    ripgrep
    ruff
    shellcheck
    texliveFull
    trash-cli
    typst
    unzip
    zip
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji

    iosevka
    (iosevka-bin.override { variant = "Aile"; })
    (iosevka-bin.override { variant = "SGr-IosevkaTerm"; })
    sarasa-gothic
  ];

  fonts.fontconfig = {
    enable = true;

    defaultFonts = {
      sansSerif = [
        "Noto Sans"
        "Noto Sans CJK JP"
      ];

      serif = [
        "Noto Serif"
        "Noto Serif CJK JP"
      ];

      monospace = [
        "Noto Sans Mono"
        "Noto Sans Mono CJK JP"
      ];

      emoji = [
        "Noto Color Emoji"
      ];
    };
  };
}
