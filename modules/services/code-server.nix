{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.code-server;

  cmd = concatStringsSep  " " [
    "${cfg.package}/bin/code-server" 
    "--auth ${cfg.auth}"
    "--bind-addr ${cfg.bindAddr}"
    (optionalString (cfg.socket != null) "--socket ${cfg.socket}")
    (optionalString cfg.disableTelemetry "--disable-telemetry")
    (optionalString (cfg.cert != null) "--cert ${cfg.cert}")
    (optionalString (cfg.certKey != null) "--cert-key ${cfg.certKey}")
  ];

  extensionsDir = "share/vscode/extensions";

in

{
  options = {
    services.code-server = {
      enable = mkEnableOption "code-server";

      package = mkOption {
        type = types.package;
        default = pkgs.code-server;
        example = literalExample "pkgs.code-server";
        description = ''
          code-server package to use.
        '';
      };

      auth = mkOption {
        type = types.enum ["password" "none"];
        default = "password";
        description = "The type of authentication to use";
      };

      cert = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "Path to certificate. Generated if no path is provided.";
      };

      certKey = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "Path to certificate key when using non-generated cert.";
      };

      disableTelemetry = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to disable telemetry.";
      };

      bindAddr = mkOption {
        type = types.str;
        default = "127.0.0.1:8080";
        description = "Address to bind to in form of host:port.";
      };

      socket = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Path to a socket (bind-addr will be ignored).";
      };

      userSettings = mkOption {
        type = types.attrs;
        default = {};
        example = literalExample ''
          {
            "update.channel" = "none";
            "[nix]"."editor.tabSize" = 2;
          }
        '';
        description = ''
          Configuration written to code-server user
          <filename>settings.json</filename>.
        '';
      };

      extensions = mkOption {
        type = types.listOf types.package;
        default = [];
        apply = unique;
        example = literalExample "[ pkgs.vscode-extensions.bbenoist.Nix ]";
        description = ''
          The extensions code-server should be started with.
          These will override but not delete manually installed ones.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.dataFile = mkMerge (
      [
        (mkIf (cfg.userSettings != {}) {
          "code-server/User/settings.json".text = builtins.toJSON cfg.userSettings;
        })
      ]

      ++

      # Links every dir for every extenion to the extension path. 
      (map (path: (
        mapAttrs' (name: extension:
          nameValuePair
            "code-server/extensions/${name}" 
            { source = "${path}/${extensionsDir}/${name}"; }
        ) (builtins.readDir (path + "/${extensionsDir}"))
      )) cfg.extensions)
    );

    systemd.user.services.code-server = {
      Unit = {
        Description = "code-server";
        After = [ "network.target" ];
      };

      Install = {
        WantedBy = [ "default.target" ];
      };

      Service = {
        ExecStart = ''${pkgs.runtimeShell} -i -c ". ~/.profile && exec ${cmd}"'';
      };
    };
  };
}
