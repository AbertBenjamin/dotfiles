{ pkgs, ... }:

{
  home.username = "benjamin";
  home.homeDirectory = "/home/benjamin";

  home.packages = with pkgs; [
    # Wayland desktop - Linux only
    sway
    niri
    waybar
    wofi
  ];

  # Deliberately NOT managed here:
  #  - kanata -> systemd/.config/systemd/user/kanata.service hardcodes
  #              /usr/bin/kanata; moving it here means updating that
  #              unit's ExecStart too (fine to do later, not yet)
}
