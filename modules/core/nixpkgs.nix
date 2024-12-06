{ config, lib, ... }:

let
  inherit (lib) mkOption seq;
  inherit (lib.types) anything pkgs unique;

  cfg = config.nixpkgs;
in
{
  options = {
    nixpkgs = {
      pkgs = mkOption { type = pkgs; };

      config = mkOption {
        internal = true;
        type = unique { message = "nixpkgs.config is set to read-only"; } anything;
      };

      overlays = mkOption {
        internal = true;
        type = unique { message = "nixpkgs.overlays is set to read-only"; } anything;
      };

      hostPlatform = mkOption {
        internal = true;
        readOnly = true;
      };

      buildPlatform = mkOption {
        internal = true;
        readOnly = true;
      };
    };
  };

  config = {
    _module.args.pkgs =
      seq cfg.config seq cfg.overlays seq cfg.hostPlatform seq cfg.buildPlatform
        cfg.pkgs;
    nixpkgs.config = cfg.pkgs.config;
    nixpkgs.overlays = cfg.pkgs.overlays;
    nixpkgs.hostPlatform = cfg.pkgs.stdenv.hostPlatform;
    nixpkgs.buildPlatform = cfg.pkgs.stdenv.buildPlatform;
  };
}
