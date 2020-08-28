{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.programs.vscode;

  vscodePname = cfg.package.pname;

  configDir = {
    "vscode" = "Code";
    "vscode-insiders" = "Code - Insiders";
    "vscodium" = "VSCodium";
  }.${vscodePname};

  extensionDir = {
    "vscode" = "vscode";
    "vscode-insiders" = "vscode-insiders";
    "vscodium" = "vscode-oss";
  }.${vscodePname};

  userDir = 
    if pkgs.stdenv.hostPlatform.isDarwin then
      "Library/Application Support/${configDir}/User"
    else
      "${config.xdg.configHome}/${configDir}/User";

  configFilePath = "${userDir}/settings.json";
  keybindingsFilePath = "${userDir}/keybindings.json";

  # TODO: On Darwin where are the extensions?
  extensionPath = ".${extensionDir}/extensions";
in

{
  options = {
    programs.vscode = {
      enable = mkEnableOption "Visual Studio Code";

      package = mkOption {
        type = types.package;
        default = pkgs.vscode;
        example = literalExample "pkgs.vscodium";
        description = ''
          Version of Visual Studio Code to install.
        '';
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
          Configuration written to Visual Studio Code's
          <filename>settings.json</filename>.
        '';
      };

      keybindings = mkOption {
        type = types.listOf (types.submodule {
          options = {

            key = mkOption {
              description = "Key or key sequence";
              type = types.str;
            };

            command = mkOption {
              description = "Name of the command to execute.";
              type = types.str;
            };

            when = mkOption {
              description = "Condition when the key is active.";
              type = types.nullOr types.str;
              default = null;
            };
          };   
        });
        description = "List of keybindings.";
        apply = map (kb: { inherit (kb) key command when; });
      };

      extensions = mkOption {
        type = types.listOf types.package;
        default = [];
        example = literalExample "[ pkgs.vscode-extensions.bbenoist.Nix ]";
        description = ''
          The extensions Visual Studio Code should be started with.
          These will override but not delete manually installed ones.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    # Adapted from https://discourse.nixos.org/t/vscode-extensions-setup/1801/2
    home.file =
      let
        toPaths = path:
          # Links every dir in path to the extension path.
          mapAttrsToList (k: v:
            {
              "${extensionPath}/${k}".source = "${path}/${k}";
            }) (builtins.readDir path);
        toSymlink = concatMap toPaths cfg.extensions;
      in
        foldr
          (a: b: a // b)
          {
            "${configFilePath}" =
              mkIf (cfg.userSettings != {}) {
                text = builtins.toJSON cfg.userSettings;
              };
            ${keybindingsFilePath} =
              mkIf (cfg.keybindings != []) {
                text = builtins.toJSON cfg.keybindings;
              };
          }
          toSymlink;
  };
}
