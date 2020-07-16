{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.protonvpn-tray;

in {
  meta.maintainers = [ maintainers.offline ];

  options = {
    services.protonvpn-tray = {
      enable = mkEnableOption "ProtonVPN tray";

      package = mkOption {
        type = types.package;
        description = "ProtonVPN package to use";
        default = pkgs.protonvpn-gui;
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.protovpn-tray = {
      Unit = {
        Description = "ProtonVPN tray";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Install = { WantedBy = [ "graphical-session.target" ]; };

      Service = {
        ExecStart = "${cfg.package}/bin/protonvpn-tray";
        Environment = [ "PATH=/run/wrappers/bin" ];
      };
    };
  };
}
