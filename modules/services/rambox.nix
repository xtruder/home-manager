{ config, lib, pkgs, ... }:

with lib;

{
  meta.maintainers = [ maintainers.offline ];

  options = {
    services.rambox = {
      enable = mkEnableOption "Rambox";
    };
  };

  config = mkIf config.services.rambox.enable {
    systemd.user.services.rambox = {
        Unit = {
          Description = "Rambox";
          After = [ "graphical-session-pre.target" ];
          PartOf = [ "graphical-session.target" ];
        };

        Install = {
          WantedBy = [ "graphical-session.target" ];
        };

        Service = {
          ExecStart = "${pkgs.rambox}/bin/rambox";
        };
    };
  };
}
