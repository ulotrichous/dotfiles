{ pkgs, ... }:

{
  setup.locales.enable = true;
  setup.nix-path.enable = true;
  setup.fonts.enable = true;
  setup.emacs.enable = true;
  setup.development = {
    enable = true;
    java.enable = false;
  };

  programs.bash.enable = true;

  documentation.enable = true;

  environment.packages = with pkgs; [
    curl
    ffmpeg
    findutils
    helix
    hunspellDicts.en_GB-ise
    hunspellDicts.en_US
    jq
    nuspell
    ripgrep
    shellcheck
    texliveFull
    trash-cli
    typst
    unzip
    zip

    inkscape
    vlc
  ];

  environment.loginShellInit = ''
    # https://fcitx-im.org/wiki/Setup_Fcitx_5
    export XMODIFIERS=@im=fcitx
    export GTK_IM_MODULE=fcitx
    export QT_IM_MODULE=fcitx

    # https://wiki.debian.org/KVM
    export LIBVIRT_DEFAULT_URI='qemu:///system';
  '';

  environment.shellAliases = {
    python = "python3";
  };
}
