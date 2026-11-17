# COSMIC. Alt her overskriver Settings ved hver switch; resten er urørt.
# ./cosmic/ speiler ~/.config/cosmic (rå RON): kopier endringer fra Settings hit.
{ config, inputs, lib, pkgs, ... }:
let
  enum = variant: { __type = "enum"; inherit variant; };
  enum' = variant: value: { __type = "enum"; inherit variant value; };
  system = action: enum' "System" [ (enum action) ];

  settingsDir = ./cosmic;
  dirNames = path: builtins.attrNames (builtins.readDir path);
  readComponent = component:
    let
      versionDir = builtins.head (dirNames (settingsDir + "/${component}"));
      keysPath = settingsDir + "/${component}/${versionDir}";
    in
    {
      version = lib.toInt (lib.removePrefix "v" versionDir);
      entries = lib.genAttrs (dirNames keysPath) (key: {
        __type = "raw";
        value = builtins.readFile (keysPath + "/${key}");
      });
    };
in
{
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable =
    config.services.displayManager.defaultSession == "cosmic";
  environment.systemPackages = [ pkgs.cosmic-monitor ];

  home-manager.users.benjamin = {
    imports = [ inputs.cosmic-manager.homeManagerModules.cosmic-manager ];

    wayland.desktopManager.cosmic = {
      enable = true;

      configFile = lib.genAttrs (dirNames settingsDir) readComponent;

      compositor = {
        autotile = true;
        autotile_behavior = enum "PerWorkspace";
        active_hint = false;
        focus_follows_cursor = false;
        cursor_follows_focus = false;
        input_default = {
          state = enum "Enabled";
          acceleration = {
            __type = "optional";
            value = {
              profile = { __type = "optional"; value = enum "Flat"; };
              # rå: cosmic-manager takler ikke negative float
              speed = { __type = "raw"; value = "-0.10288643756187243"; };
            };
          };
        };
        xkb_config = {
          rules = "";
          model = "pc105";
          layout = "no,no";
          variant = ",winkeys";
          options = { __type = "optional"; value = "terminate:ctrl_alt_bksp,lv3:ralt_switch"; };
          repeat_delay = 600;
          repeat_rate = 25;
        };
      };

      systemActions = {
        __type = "map";
        value = [
          { key = enum "Terminal"; value = "${pkgs.ghostty}/bin/ghostty --gtk-single-instance=true"; }
        ];
      };

      # Oppå standardene (som dekker Super+hjkl, Super+1..9), likt aerospace
      shortcuts = [
        { key = "Super";             action = system "AppLibrary"; }
        { key = "Alt+space";         action = system "Launcher"; }
        { key = "Super+Shift+s";     action = system "Screenshot"; }
        { key = "Super+F11";         action = enum "Disable"; }
        { key = "Super+m";           action = enum "Fullscreen"; }
        { key = "Super+f";           action = enum "Maximize"; }
        { key = "Super+o";           action = enum "LastWorkspace"; }
        { key = "Super+e";           action = enum "ToggleOrientation"; }
        { key = "Super+Shift+space"; action = enum "ToggleWindowFloating"; }
        { key = "Super+n";           action = enum' "MoveToOutput" [ (enum "Right") ]; }
        { key = "Super+p";           action = enum' "MoveToOutput" [ (enum "Left") ]; }
      ];
    };
  };
}
