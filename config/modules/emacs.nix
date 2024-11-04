{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkOption;
  inherit (lib.types) bool;

  cfg = config.setup.emacs;

  etc = config.environment.etc;

  package = pkgs.emacs-with-packages.override {
    emacs = pkgs.emacs30;
  };

  emacsService = pkgs.writeTextFile {
    name = "emacs";
    destination = "/share/systemd/user/emacs.service";
    text = ''
      [Unit]
      Description=Emacs text editor
      Documentation=info:emacs man:emacs(1) https://gnu.org/software/emacs/
      After=default.target

      [Service]
      Type=notify
      ExecStart=${pkgs.runtimeShell} -c 'source ${etc.set-environment.source}; exec ${package}/bin/emacs --fg-daemon'
      ExecStop=${package}/bin/emacsclient --eval (kill-emacs)
      Restart=on-failure

      Environment=XMODIFIERS=@im=none

      # Emacs will exit with status 15 after having received SIGTERM, which
      # is the default "KillSignal" value systemd uses to stop services.
      SuccessExitStatus=15

      [Install]
      WantedBy=default.target
    '';
  };
in
{
  options = {
    setup.emacs = {
      enable = mkOption {
        type = bool;
        default = false;
      };
    };
  };

  config = mkIf cfg.enable {
    environment.packages = [
      package
      emacsService
    ];
  };
}
