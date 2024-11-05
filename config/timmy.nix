{ pkgs, ... }:

{
  setup.locales.enable = true;
  setup.nix-path.enable = true;
  setup.nix-index.enable = true;
  setup.emacs.enable = true;
  setup.documentation.enable = true;
  setup.development.enable = true;

  programs.bash.enable = true;

  documentation.enable = true;

  environment.packages = with pkgs; [
    curl
    findutils
    helix
    hunspellDicts.en_GB-ise
    hunspellDicts.en_US
    jq
    nuspell
    ripgrep
    shellcheck
    trash-cli
    tshark
    unzip
    zip
  ];

  environment.shellAliases = {
    python = "python3";
  };

  fonts.fontconfig.enable = true;
  fonts.packages = with pkgs; [
    (iosevka-bin.override { variant = "Aile"; })
    (iosevka-bin.override { variant = "SGr-IosevkaTerm"; })
    iosevka
    sarasa-gothic
  ];
}
