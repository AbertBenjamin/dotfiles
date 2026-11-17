# Felles home-manager-oppsett. Skrivebordene ligger i desktops/.
{ lib, pkgs, ... }:
{
  home.stateVersion = "26.05";

  # Rex-server, nås over SSH (ssh://benjamin@<maskin>)
  programs.rex.enable = true;
  services.rex.enable = true;
  # Rex legger en TERM-fallback i ~/.ssh/config, som krever programs.ssh
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
  };

  # FootCtrlPlus-pedalen via «Midi Through», så REAPER alltid finner den
  systemd.user.services.footctrl-bridge = {
    Unit = {
      Description = "Kobler FootCtrlPlus til ALSA Midi Through (stabil port for REAPER)";
      After = [ "pipewire.service" ];
    };
    Service = {
      ExecStart = toString (pkgs.writeShellScript "footctrl-bridge" ''
        export PATH=${lib.makeBinPath (with pkgs; [ alsa-utils gawk gnugrep gnused coreutils ])}
        ${builtins.readFile ./scripts/footctrl-bridge}
      '');
      Restart = "always";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
