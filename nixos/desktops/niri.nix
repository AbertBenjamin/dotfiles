# niri med waybar og wofi. Configfilene i ./niri/ legges ut av home-manager.
{ pkgs, ... }:
{
  programs.niri.enable = true;
  environment.systemPackages = with pkgs; [ waybar wofi xwayland-satellite ];

  home-manager.users.benjamin.xdg.configFile = {
    "niri/config.kdl".source = ./niri/config.kdl;
    "waybar".source = ./niri/waybar;
    "wofi".source = ./niri/wofi;
  };
}
