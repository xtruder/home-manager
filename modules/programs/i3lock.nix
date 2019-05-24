{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.programs.i3lock;

  cmd = (builtins.parseDrvName cfg.package.name).name;

  lockCmd = concatStringsSep " " (filter (value: value != "") [
    "${cfg.package}/bin/${cmd}"

    # general
    (optionalString (cfg.background.color != null)
      "--color=${cfg.background.color}")
    (optionalString (cfg.background.image != null)
      "--image=${cfg.background.image}")
    (optionalString (cfg.background.blur != null)
      "--blur=${toString cfg.background.blur}")
    (optionalString cfg.beep "--beep")
    (optionalString cfg.indicator "--indicator")
    (optionalString (cfg.pointer != null) "--pointer=${cfg.pointer}")

    # clock
    (optionalString cfg.clock.enable "--clock")
    (optionalString cfg.clock.enable "--timestr=${cfg.clock.timeStr}")
    (optionalString cfg.clock.enable "--datestr=${cfg.clock.dateStr}")

    # text
    (optionalString (cfg.text.verify != null)
      "--veriftext=${cfg.text.verify}")
    (optionalString (cfg.text.wrong != null)
      "--wrongtext=${cfg.text.wrong}")
    (optionalString (cfg.text.noinput != null)
      "--noinputtext=${cfg.text.noinput}")
    (optionalString (cfg.text.lock != null)
      "--locktext=${cfg.text.lock}")
    (optionalString (cfg.text.lockFailed != null)
      "--lockfailedtext=${cfg.text.lockFailed}")
    (optionalString (cfg.text.greeter != null)
      "--greetertext=${cfg.text.greeter}")

    # text font
    (optionalString (cfg.text.font.time != null)
      "--time-font=${cfg.text.font.time}")
    (optionalString (cfg.text.font.date != null)
      "--date-font=${cfg.text.font.date}")
    (optionalString (cfg.text.font.layout != null)
      "--layout-font=${cfg.text.font.layout}")
    (optionalString (cfg.text.font.verify != null)
      "--verif-font=${cfg.text.font.verify}")
    (optionalString (cfg.text.font.wrong != null)
      "--wrong-font=${cfg.text.font.wrong}")
    (optionalString (cfg.text.font.greeter != null)
      "--greeter-font=${cfg.text.font.greeter}")

    # text size
    (optionalString (cfg.text.size.time != null)
      "--time-size=${toString cfg.text.size.time}")
    (optionalString (cfg.text.size.date != null)
      "--date-size=${toString cfg.text.size.date}")
    (optionalString (cfg.text.size.layout != null)
      "--layout-size=${toString cfg.text.size.layout}")
    (optionalString (cfg.text.size.verify != null)
      "--verif-size=${toString cfg.text.size.verify}")
    (optionalString (cfg.text.size.wrong != null)
      "--wrong-size=${toString cfg.text.size.wrong}")
    (optionalString (cfg.text.size.greeter != null)
      "--greeter-size=${toString cfg.text.size.greeter}")

    # colors
    (optionalString (cfg.colors.insideVerify != null)
      "--insidevercolor=${cfg.colors.insideVerify}")
    (optionalString (cfg.colors.ringVerify != null)
      "--ringvercolor=${cfg.colors.ringVerify}")
    (optionalString (cfg.colors.insideWrong != null)
      "--insidewrongcolor=${cfg.colors.insideWrong}")
    (optionalString (cfg.colors.ringWrong != null)
      "--ringwrongcolor=${cfg.colors.ringWrong}")
    (optionalString (cfg.colors.inside != null)
      "--insidecolor=${cfg.colors.inside}")
    (optionalString (cfg.colors.ring != null)
      "--ringcolor=${cfg.colors.ring}")
    (optionalString (cfg.colors.line != null)
      "--linecolor=${cfg.colors.line}")
    (optionalString (cfg.colors.separator != null)
      "--separatorcolor=${cfg.colors.separator}")
    (optionalString (cfg.colors.verify != null)
      "--verifcolor=${cfg.colors.verify}")
    (optionalString (cfg.colors.wrong != null)
      "--wrongcolor=${cfg.colors.wrong}")
    (optionalString (cfg.colors.time != null)
      "--timecolor=${cfg.colors.time}")
    (optionalString (cfg.colors.date != null)
      "--datecolor=${cfg.colors.date}")
    (optionalString (cfg.colors.layout != null)
      "--layoutcolor=${cfg.colors.layout}")
    (optionalString (cfg.colors.keyhl != null)
      "--keyhlcolor=${cfg.colors.keyhl}")
    (optionalString (cfg.colors.bshl != null)
      "--bshlcolor=${cfg.colors.bshl}")
  ]);

  lockScript = pkgs.writeScript "i3lock.sh" ''
    #!${pkgs.stdenv.shell}
    ${cfg.extraCommand}
    ${lockCmd}
  '';
in {
  options.programs.i3lock = {
    enable = mkEnableOption "i3lock: a simple screen locker like slock.";

    package = mkOption {
      description = "Package to use for i3lock.";
      type = types.package;
      default = pkgs.i3lock-color;
      defaultText = "pkgs.i3lock-color";
    };

    background = {
      color = mkOption {
        description = "Background color to use for i3lock.";
        type = types.nullOr types.str;
        default = null;
      };

      image = mkOption {
        description = "Background image file to use for i3lock.";
        type = types.nullOr types.path;
        default = null;
      };

      blur = mkOption {
        description = "Blur the current screen and use that as a background.";
        type = types.nullOr types.int;
        default = null;
      };
    };

    beep = mkOption {
      description = "Whether to enable i3lock beeping.";
      type = types.bool;
      default = false;
    };

    indicator = mkOption {
      description = "Whether to make i3lock indicator always be visible.";
      type = types.bool;
      default = false;
    };

    pointer = mkOption {
      description = "Whether to show mouse pointer, or display a hardcoded Windows-Pointer.";
      default = null;
      type = types.nullOr (types.enum ["default" "win"]);
    };

    clock = {
      enable = mkEnableOption "show clock on i3lock.";

      timeStr = mkOption {
        description = "i3lock clock time format string.";
        type = types.str;
        default = "%H:%M:%S";
      };

      dateStr = mkOption {
        description = "i3lock clock date format string.";
        type = types.str;
        default = "%A, %m %Y";
      };
    };

    text = {
      verify = mkOption {
        description = "i3lock text dispayed if user is verified.";
        type = types.nullOr types.str;
        default = null;
        example = "Drinking verification can...";
      };

      wrong = mkOption {
        description = "i3lock text displayed if verification fails.";
        type = types.nullOr types.str;
        default = null;
        example = "Nope!";
      };

      noinput = mkOption {
        description = "i3lock text to be shown upon pressing backspace without anything to delete.";
        type = types.nullOr types.str;
        default = null;
      };

      lock = mkOption {
        description = "i3lock text to be shown while acquiring pointer and keyboard focus.";
        type = types.nullOr types.str;
        default = null;
      };

      lockFailed = mkOption {
        description = "i3lock text to be shown after failing to acquire pointer and keyboard focus.";
        type = types.nullOr types.str;
        default = null;
      };

      greeter = mkOption {
        description = "i3lock text to be shown for greeter.";
        type = types.nullOr types.str;
        default = null;
      };

      font = {
        time = mkOption {
          description = "i3lock font to use for diplaying time text.";
          type = types.nullOr types.str;
          default = cfg.text.font.default;
        };

        date = mkOption {
          description = "i3lock font to use for diplaying date text.";
          type = types.nullOr types.str;
          default = cfg.text.font.default;
        }; 

        layout = mkOption {
          description = "i3lock font to use for diplaying layout text.";
          type = types.nullOr types.str;
          default = cfg.text.font.default;
        };

        verify = mkOption {
          description = "i3lock font to use for diplaying verify text.";
          type = types.nullOr types.str;
          default = cfg.text.font.default;
        };

        wrong = mkOption {
          description = "i3lock font to use for diplaying wrongi text.";
          type = types.nullOr types.str;
          default = cfg.text.font.default;
        };

        greeter = mkOption {
          description = "i3lock font to use for diplaying greeter text.";
          type = types.nullOr types.str;
          default = cfg.text.font.default;
        };

        default = mkOption {
          description = "i3lock default font.";
          type = types.nullOr types.str;
          default = null;
        };
      };

      size = {
        time = mkOption {
          description = "i3lock text size for displaying time text.";
          type = types.nullOr types.int;
          default = cfg.text.size.default;
        };

        date = mkOption {
          description = "i3lock text size for displaying date text.";
          type = types.nullOr types.int;
          default = cfg.text.size.default;
        }; 

        layout = mkOption {
          description = "i3lock text size for displaying layout text.";
          type = types.nullOr types.int;
          default = cfg.text.size.default;
        };

        verify = mkOption {
          description = "i3lock text size for displaying verify text.";
          type = types.nullOr types.int;
          default = cfg.text.size.default;
        };

        wrong = mkOption {
          description = "i3lock text size for displaying wrong text.";
          type = types.nullOr types.int;
          default = cfg.text.size.default;
        };

        greeter = mkOption {
          description = "i3lock text size for displaying greeter text.";
          type = types.nullOr types.int;
          default = cfg.text.size.default;
        };

        default = mkOption {
          description = "i3lock default text size";
          type = types.nullOr types.int;
          default = null;
        };
      };
    };

    colors = {
      insideVerify = mkOption {
        description = "i3lock inside verify color";
        type = types.nullOr types.str;
        default = null;
      };

      ringVerify = mkOption {
        description = "i3lock ring verify color.";
        type = types.nullOr types.str;
        default = null;
      };

      insideWrong = mkOption {
        description = "3lock inside wrong color.";
        type = types.nullOr types.str;
        default = null;
      };

      ringWrong = mkOption {
        description = "i3lock ring wrong color.";
        type = types.nullOr types.str;
        default = null;
      };

      inside = mkOption {
        description = "3lock inside color.";
        type = types.nullOr types.str;
        default = null;
      };

      ring = mkOption {
        description = "i3lock ring color.";
        type = types.nullOr types.str;
        default = null;
      };

      line = mkOption {
        description = "i3lock line color.";
        type = types.nullOr types.str;
        default = null;
      };

      separator = mkOption {
        description = "i3lock seprarator color.";
        type = types.nullOr types.str;
        default = null;
      };

      verify = mkOption {
        description = "i3lock verify color.";
        type = types.nullOr types.str;
        default = null;
      };

      wrong = mkOption {
        description = "i3lock wrong color.";
        type = types.nullOr types.str;
        default = null;
      };

      time = mkOption {
        description = "i3lock time color.";
        type = types.nullOr types.str;
        default = null;
      };

      date = mkOption {
        description = "i3lock date color.";
        type = types.nullOr types.str;
        default = null;
      };

      layout = mkOption {
        description = "i3lock layout color.";
        type = types.nullOr types.str;
        default = null;
      };

      keyhl = mkOption {
        description = "i3lock key hold color.";
        type = types.nullOr types.str;
        default = null;
      };

      bshl = mkOption {
        description = "i3lock backspace hold color.";
        type = types.nullOr types.str;
        default = null;
      };
    };

    extraCommands = mkOption {
      description = "Extra commands to run before running i3lock.";
      default = "";
      type = types.lines;
      example = ''
        ''${pkgs.scrot}/bin/scrot /tmp/screen_locked.png
        ''${pkgs.imagemagick}/bin/convert /tmp/screen_locked.png \
          -scale 10% -scale 1000% /tmp/screen_locked.png
      '';
    };
  };

  config = mkIf cfg.enable {
    services.screen-locker = {
      enable = mkDefault true;
      lockCmd = mkDefault (if (cfg.extraCommands == "") then lockCmd else lockScript);
    };
  };
}
