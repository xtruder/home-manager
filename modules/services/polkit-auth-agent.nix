{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.polkit-auth-agent;

  defaultCmd = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"; 

in {
  options = {
    services.polkit-auth-agent = {
      enable = mkEnableOption "Polkit auth agent";

      command = mkOption {
        description = "Command to run to start polkit auth agent";
        type = types.str;
        default = defaultCmd;
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.polkit-auth-agent = {
      Unit = {
        Description = "Polkit authentication agent";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = cfg.command;
        Restart = "on-failure";
      };

      Install = { WantedBy = [ "graphical-session.target" ]; };
    };
  };
} 
