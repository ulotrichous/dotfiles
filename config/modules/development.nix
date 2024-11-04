{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkMerge mkOption;
  inherit (lib.types) bool;

  cfg = config.setup.development;
in
{
  options = {
    setup.development = {
      enable = mkOption {
        type = bool;
        default = false;
      };

      c.enable = mkOption {
        type = bool;
        default = true;
      };

      haskell.enable = mkOption {
        type = bool;
        default = true;
      };

      java.enable = mkOption {
        type = bool;
        default = true;
      };

      nix.enable = mkOption {
        type = bool;
        default = true;
      };

      nodejs.enable = mkOption {
        type = bool;
        default = true;
      };

      python.enable = mkOption {
        type = bool;
        default = true;
      };

      rust.enable = mkOption {
        type = bool;
        default = true;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      environment.packages = with pkgs; [
        gdb
        plantuml
        shellcheck
      ];

      programs.direnv.enable = true;

      programs.git = {
        enable = true;
        settings = {
          commit.gpgsign = true;
          core.excludesFile = "${pkgs.gitignore}";
          init.defaultBranch = "main";

          include.path = "~/.config/git/config";
        };
      };
    }

    (mkIf cfg.c.enable {
      environment.packages = with pkgs; [
        clang-tools
        cmake
        gcc
        gnumake
        meson
        ninja
        valgrind
      ];
    })

    (mkIf cfg.haskell.enable {
      environment.packages = with pkgs; [
        cabal-install
        ghc
        haskell-language-server
        stylish-haskell
      ];
    })

    (mkIf cfg.java.enable {
      environment.packages = with pkgs; [
        jdk
        jdt-language-server
      ];
    })

    (mkIf cfg.nix.enable {
      environment.packages = with pkgs; [
        nixd
        nixfmt-rfc-style
      ];
    })

    (mkIf cfg.nodejs.enable {
      environment.packages = with pkgs; [
        nodejs
        nodePackages.typescript-language-server
      ];
    })

    (mkIf cfg.python.enable {
      environment.packages = with pkgs; [
        hatch
        ruff
      ];
    })

    (mkIf cfg.rust.enable {
      environment.packages = with pkgs; [
        cargo
        clippy
        rust-analyzer
        rustc
        rustfmt
      ];
    })
  ]);
}
