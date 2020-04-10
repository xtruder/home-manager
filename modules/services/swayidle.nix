{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.swayidle;

  timeoutOptions = {
    options = {
      duration = mkOption {
        description = "Duration after which command is triggered";
        type = types.int;
      };

      command = mkOption {
        description = "Command to when timeout is triggered";
        type = types.str;
      };

      resume = mkOption {
        description = "Command to run on resume";
        type = types.nullOr types.str;
        default = null;
      };
    };
  };

  args =
    (map (t: 
      "timeout ${toString t.duration} ${escapeShellArg t.command} " +
      (optionalString (t.resume != null) "resume ${escapeShellArg t.resume}")
    ) cfg.timeout)
    ++ (map (c: "before-sleep ${escapeShellArg c}") cfg.beforeSleep)
    ++ (map (c: "lock ${escapeShellArg c}") cfg.lock)
    ++ (map (c: "unlock ${escapeShellArg c}") cfg.unlock);
in {
  options.services.swayidle = {
    enable = mkEnableOption "swayidle";

    package = mkOption {
      type = types.package;
      default = pkgs.swayidle;
      description = "Package to use";
    };

    timeout = mkOption {
      type = types.listOf (types.submodule timeoutOptions);
      default = [];
      description = "List of commands to run on timeout";
    };

    beforeSleep = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of commands to run before sleep";
    };

    lock = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of commands to run on lock";
    };

    unlock = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of commands to run on unlock";
    };
  };

  config.wayland.windowManager.sway.config.startup = [{
    command = concatStringsSep " "
      ([ "${cfg.package}/bin/swayidle" "-w" ] ++ args);
  }];
}
