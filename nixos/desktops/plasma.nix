# KDE Plasma. Bare nøklene her styres; resten kan endres i Systeminnstillinger.
{ config, inputs, pkgs, ... }:
{
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = {
    enable = config.services.displayManager.defaultSession == "plasma";
    wayland.enable = true;
  };

  home-manager.users.benjamin = {
    imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

    # COSMIC-modulen setter qt5ct globalt, og da melder KDE-portalen lyst tema
    xdg.configFile."plasma-workspace/env/qt-kde.sh".text = ''
      export QT_QPA_PLATFORMTHEME=kde
      export QT_STYLE_OVERRIDE=Breeze
    '';

    home.packages = with pkgs; [ morewaita-icon-theme whitesur-kde apple-cursor ];

    programs.plasma = {
      enable = true;
      workspace = {
        theme = "WhiteSur-dark";
        iconTheme = "MoreWaita";
        cursor.theme = "macOS";
        windowDecorations = {
          library = "org.kde.kwin.aurorae";
          theme = "__aurorae__svg__WhiteSur-dark";
        };
      };
      kwin.virtualDesktops = { number = 9; rows = 1; };
      kwin.titlebarButtons = { left = [ "close" "minimize" "maximize" ]; right = [ ]; };
      configFile.kwinrc = {
        "org.kde.kdecoration2".BorderSize = "None";
        Windows.BorderlessMaximizedWindows = true;
        TabBox = { LayoutName = "thumbnail_grid"; HighlightWindows = false; };
      };
      input.mice = [
        {
          name = "BenQ ZOWIE BenQ ZOWIE Gaming Mouse";
          vendorId = "04a5";
          productId = "8006";
          accelerationProfile = "none";
        }
      ];
      krunner.position = "center";
      configFile.kwinrc.ModifierOnlyShortcuts.Meta =
        "org.kde.kglobalaccel,/component/kwin,org.kde.kglobalaccel.Component,invokeShortcut,Overview";
      configFile.baloofilerc."Basic Settings"."Indexing-Enabled" = false;

      # Som COSMIC: toppanel og flytende dokk. Endringer i panelinnstillingene
      # overskrives ved neste innlogging etter en switch.
      panels = [
        {
          location = "top";
          height = 32;
          screen = "all";
          widgets = [
            "org.kde.plasma.pager"
            "org.kde.plasma.panelspacer"
            { digitalClock = { time.format = "24h"; date.format = "longDate"; }; }
            "org.kde.plasma.panelspacer"
            "org.kde.plasma.systemtray"
          ];
        }
        {
          location = "bottom";
          height = 52;
          floating = true;
          lengthMode = "fit";
          alignment = "center";
          hiding = "dodgewindows";
          screen = "all";
          widgets = [
            {
              iconTasks.launchers = map (a: "applications:${a}.desktop") [
                "firefox" "com.mitchellh.ghostty" "org.gnome.Nautilus"
                "spotify" "discord" "steam" "cockos-reaper"
              ];
            }
          ];
        }
      ];

      shortcuts = {
        kwin = {
          "Switch Window Left" = "Meta+H";
          "Switch Window Down" = "Meta+J";
          "Switch Window Up" = "Meta+K";
          "Switch Window Right" = "Meta+L";
          "Window Quick Tile Left" = "Meta+Shift+H";
          "Window Quick Tile Bottom" = "Meta+Shift+J";
          "Window Quick Tile Top" = "Meta+Shift+K";
          "Window Quick Tile Right" = "Meta+Shift+L";
          "Window Maximize" = "Meta+F";
          "Window Fullscreen" = "Meta+M";
          "Window to Next Screen" = "Meta+N";
          "Window to Previous Screen" = "Meta+P";
        }
        # Norsk tastatur: KDE kan lagre Shift+tall som symbolet, så begge bindes
        // builtins.listToAttrs (builtins.concatLists (pkgs.lib.imap1 (n: sym: [
          { name = "Switch to Desktop ${toString n}"; value = "Meta+${toString n}"; }
          { name = "Window to Desktop ${toString n}"; value = [ "Meta+Shift+${toString n}" "Meta+${sym}" ]; }
        ]) [ "!" "\"" "#" "¤" "%" "&" "/" "(" ")" ]));

        # Frigjør tastene over fra KDE sine standarder
        plasmashell = builtins.listToAttrs (map (n: {
          name = "activate task manager entry ${toString n}"; value = [ ];
        }) [ 1 2 3 4 5 6 7 8 9 ]);
        ksmserver."Lock Session" = "Screensaver";
        "services/org.kde.dolphin.desktop"._launch = [ ];
        kscreen.ShowOSD = "Display";
      };
    };
  };
}
