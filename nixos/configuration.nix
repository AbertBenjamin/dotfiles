{ config, lib, pkgs, ... }:
let
  sforzando = import ./pkgs/sforzando.nix { inherit pkgs lib; };
  ssl2 = "Solid_State_Logic_SSL_2__Mk_II-00";
  mic1 = "alsa_input.usb-${ssl2}.HiFi__Mic1__source";
in
{
  imports = [ ./hardware-configuration.nix ];

  system.stateVersion = "26.05";
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Boot og kjerne
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  # 7.2.0 ga USB-lyd-dropouts på SSL 2+; ved tilbakefall: forrige generasjon og fjern linja
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.extraModulePackages = [ config.boot.kernelPackages.it87 ];
  boot.kernelModules = [ "it87" "ntsync" ];
  boot.extraModprobeConfig = "options it87 ignore_resource_conflict=1";
  boot.kernelParams = [ "nvidia-drm.modeset=1" "acpi_enforce_resources=lax" "pcie_aspm=off" ];
  # Stille frys (GPU-heng) blir panic og automatisk reboot i stedet
  boot.kernel.sysctl = {
    "kernel.hung_task_panic" = 1;
    "kernel.panic" = 20;
  };
  # Uten swap ble minnepress en livelock (hard reset 2026-08-30)
  zramSwap = {
    enable = true;
    memoryPercent = 50;
    algorithm = "zstd";
  };

  # System
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Oslo";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    keyMap = "no";
  };
  services.xserver.xkb.layout = "no";

  users.users.benjamin = {
    isNormalUser = true;
    linger = true; # brukertjenester (Rex) kjører uten innlogging
    extraGroups = [ "wheel" "audio" "docker" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      bat eza delta fd fzf ripgrep jq yq-go fastfetch tree-sitter gcc unzip
      wl-clipboard direnv zoxide
      nerd-fonts.jetbrains-mono
      go lua kotlin-cli detekt nodejs rustup gh sops docker
      tree neovim zsh ghostty alacritty yazi tmux stow git git-lfs
      spotify discord reaper tuxguitar musescore freecad zapzap
      bolt-launcher corectrl neural-amp-modeler-lv2
      alsa-utils blueman qalculate-gtk udiskie claude-code
    ];
  };
  security.polkit.enable = true;
  security.sudo.wheelNeedsPassword = false;
  # Rett inn ved oppstart, så Sunshine kan nås fra Moonlight etter omstart
  services.displayManager.autoLogin = {
    enable = true;
    user = "benjamin";
  };
  # Velger også innloggingsside: plasma → SDDM, cosmic → cosmic-greeter
  services.displayManager.defaultSession = "plasma";

  environment.systemPackages = with pkgs; [
    vim wget bibata-cursors lm_sensors easyeffects deepfilternet pipewire.jack
    kubectl nautilus
    zenmonitor ryzenadj
    yabridge yabridgectl wineWow64Packages.staging
    zenity # fil-dialog for Plogue-plugins
  ];
  environment.variables = {
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";
    GTK_THEME = "Adwaita:dark";
    GTK_IM_MODULE = "simple"; # dead keys i GTK-apper under cosmic-comp
    EDITOR = "nvim";
    VISUAL = "nvim";
    QT_STYLE_OVERRIDE = "adwaita-dark";
  };
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
    # HTTPS i WebKitGTK-webviews (TONE3000 i REAPER)
    GIO_EXTRA_MODULES = [ "${pkgs.glib-networking}/lib/gio/modules" ];
  };

  # Maskinvare
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    powerManagement.enable = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.xpadneo.enable = true;
  hardware.alsa.enablePersistence = true;
  security.wrappers.ryzenadj = {
    source = "${pkgs.ryzenadj}/bin/ryzenadj";
    capabilities = "cap_sys_admin+ep";
    owner = "root";
    group = "root";
  };

  services.hardware.openrgb.enable = true;
  systemd.services.ram-rgb = {
    description = "Set RAM RGB color";
    wantedBy = [ "multi-user.target" ];
    after = [ "openrgb.service" ];
    wants = [ "openrgb.service" ];
    path = [ pkgs.openrgb pkgs.gnugrep pkgs.coreutils pkgs.systemd ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    # RAM-kontrollerne svarer ikke alltid på første skann etter boot
    script = ''
      for attempt in $(seq 1 6); do
        ids=$(openrgb --list-devices 2>/dev/null | grep -E '^[0-9]+: ENE DRAM' | cut -d: -f1)
        if [ "$(echo $ids | wc -w)" -eq 4 ]; then
          args=""
          for id in $ids; do args="$args -d $id -m static -c FFFFFF"; done
          openrgb $args && exit 0
        fi
        systemctl restart openrgb.service
        sleep 5
      done
      exit 1
    '';
  };

  # Lyd: SSL 2+ MkII
  security.rtkit.enable = true;
  security.pam.loginLimits = [
    { domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
    { domain = "@audio"; item = "rtprio";  type = "-"; value = "95"; }
  ];
  services.pipewire = {
    enable = true;
    jack.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.extraConfig."51-ssl2-names"."monitor.alsa.rules" =
      let
        rename = match: props: { matches = [ match ]; actions.update-props = props; };
        node = name: label: rename { "node.name" = name; } { "node.description" = label; "node.nick" = label; };
      in
      [
        (rename { "device.name" = "alsa_card.usb-${ssl2}"; } { "device.description" = "SSL 2+ MkII"; })
        (node mic1 "SSL 2+ Mic 1")
        (node "alsa_input.usb-${ssl2}.HiFi__Mic2__source" "SSL 2+ Mic 2")
        (node "alsa_output.usb-${ssl2}.HiFi__Line1__sink" "SSL 2+ Speakers")
        (node "alsa_output.usb-${ssl2}.HiFi__Line2__sink" "SSL 2+ Line Out 3/4")
        (node "alsa_input.hw_II_0" "SSL 2+ Raw In 8ch")
        (node "alsa_output.hw_II_0" "SSL 2+ Raw Out 6ch")
      ];
    # 128/64 ga XRUN-dropouts på SSL 2+
    extraConfig.pipewire."99-lowlatency"."context.properties" = {
      "default.clock.rate" = 48000;
      "default.clock.quantum" = 512;
      "default.clock.min-quantum" = 256;
      "default.clock.max-quantum" = 2048;
    };
    # SM57 på Mic1 som egen mono-kilde
    extraConfig.pipewire."60-sm57-mono"."context.modules" = [
      {
        name = "libpipewire-module-loopback";
        args = {
          "capture.props" = {
            "node.name" = "capture.sm57";
            "target.object" = mic1;
            "audio.position" = [ "FL" ];
            "stream.dont-remix" = true;
            "node.passive" = true;
          };
          "playback.props" = {
            "node.name" = "sm57_mono";
            "node.description" = "SM57";
            "node.nick" = "SM57";
            "media.class" = "Audio/Source";
            "audio.position" = [ "FL" "FR" ];
          };
        };
      }
    ];
  };
  systemd.user.services.mic-level = {
    description = "Pin SM57/Mic1 input level";
    wantedBy = [ "graphical-session.target" ];
    after = [ "wireplumber.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      for i in $(seq 1 30); do
        ${pkgs.pulseaudio}/bin/pactl set-source-volume \
          ${mic1} 140% \
          && exit 0
        sleep 1
      done
      exit 1
    '';
  };

  # REAPER, sforzando og plugins. sforzando lagrer full sti i prosjektene, så
  # instrumenter lastes via /opt/sfz (samme symlenke på Macen).
  systemd.tmpfiles.rules = [
    "d /mnt/data 0755 benjamin users -"
    "L+ /opt/Plogue - - - - ${sforzando}/opt/Plogue"
    "L+ /usr/bin/zenity - - - - ${pkgs.zenity}/bin/zenity"
    "d /usr/lib/vst3 0755 root root -"
    "L+ /usr/lib/vst3/sforzando.vst3 - - - - ${sforzando}/vst3/sforzando.vst3"
    "L+ /home/benjamin/.vst3/sforzando.vst3 - - - - ${sforzando}/vst3/sforzando.vst3"
    "L+ /opt/sfz - - - - /home/benjamin/Music/sfz"
    "L+ /home/benjamin/.config/REAPER/UserPlugins/reaper_reapack-x86_64.so - - - - ${pkgs.reaper-reapack-extension}/UserPlugins/reaper_reapack-x86_64.so"
    "L+ /home/benjamin/.config/REAPER/UserPlugins/reaper_sws-x86_64.so - - - - ${pkgs.reaper-sws-extension}/UserPlugins/reaper_sws-x86_64.so"
  ];

  # Programmer
  programs.zsh.enable = true;
  programs.firefox = {
    enable = true;
    preferences = { "general.autoScroll" = true; };
  };
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };
  programs.gamescope.enable = true;
  programs.corectrl.enable = true;
  programs.xwayland.enable = true;
  programs.appimage = {
    enable = true;
    binfmt = true;
  };
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      libx11 libXext libxrender libxtst libxi libGL stdenv.cc.cc.lib
      fontconfig freetype libpng zlib bzip2 brotli expat alsa-lib
    ];
  };
  # jdk25 som standard, og fast sti for Gradle toolchains og kotlin-lsp
  programs.java = {
    enable = true;
    package = pkgs.jdk25;
  };
  environment.etc."jdks/25".source = pkgs.jdk25.home;
  # Lokal Docker-motor (Claude Code sin docker-sandkasse)
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  # Nautilus som standard filbehandler
  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "ghostty";
  };
  services.gnome.sushi.enable = true;
  xdg.mime.defaultApplications."inode/directory" = "org.gnome.Nautilus.desktop";

  # Nett og tjenester
  services.openssh.enable = true;
  fileSystems."/mnt/data" = {
    device = "//192.168.1.39/data";
    fsType = "cifs";
    options = [
      "credentials=/etc/nixos/smb-credentials"
      "uid=1000"
      "gid=100"
      "noauto"
      "x-systemd.automount"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=30s"
      "_netdev"
    ];
  };
  # VPN til hjemmeserveren (peer10). Nøklene ligger i /etc/wireguard.
  networking.wireguard.interfaces.wg-home = {
    ips = [ "10.13.13.11/32" ];
    privateKeyFile = "/etc/wireguard/wg-home.key";
    peers = [{
      publicKey = "6STD/YglPeG3RBOclf50kJXtRaAyQ8c9VG7maP5dgS0=";
      presharedKeyFile = "/etc/wireguard/wg-home.psk";
      endpoint = "192.168.1.39:51820";
      allowedIPs = [ "10.13.13.0/24" ];
      persistentKeepalive = 25;
    }];
  };
  # REAPER-prosjekter og sfz synkes med Macen via hjemmeserveren. Delinger må
  # deklareres her; de som legges til i GUI-et forsvinner ved rebuild.
  services.syncthing = {
    enable = true;
    user = "benjamin";
    group = "users";
    dataDir = "/home/benjamin";
    configDir = "/home/benjamin/.config/syncthing";
    openDefaultPorts = true;
    overrideDevices = false;
    overrideFolders = false;
    settings.devices.homeserver = {
      id = "P7ZK2FB-K3JK3MS-6DWGLFP-T4PBOQI-P43AG66-OPZYILL-MGGBUJD-G45XZQ2";
      addresses = [ "tcp://192.168.1.39:22000" ];
    };
    settings.folders.reaper = {
      label = "REAPER";
      path = "/home/benjamin/Music/REAPER";
      devices = [ "homeserver" ];
    };
    settings.folders.sfz = {
      label = "sfz";
      path = "/home/benjamin/Music/sfz";
      devices = [ "homeserver" ];
    };
  };
  # Fjernstyring fra Moonlight. Web-UI: https://127.0.0.1:47990
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };
  # Start på nytt også etter «Quit» i panelikonet
  systemd.user.services.sunshine.serviceConfig.Restart = lib.mkForce "always";
}
