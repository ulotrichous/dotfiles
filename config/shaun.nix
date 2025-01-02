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
    inkscape
    iverilog
    mpv
    pass-wayland
    pinentry-qt
    pipx
    poweralertd
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
