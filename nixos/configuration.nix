# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let
  # unstable = import (fetchTarball "https://nixos.org/channels/nixpkgs-unstable/nixexprs.tar.xz") {
  #   config = config.nixpkgs.config;
  # };

  # --- Native Linux sforzando (Plogue), patchet for NixOS ---
  # Deklarativ, GC-sikker erstatning for den manuelle /opt/Plogue-installasjonen.
  # Pakker ut vendor-.deb-ene, baker RPATH inn i motoren/plugin-en, og legger
  # inn en curl-kompatibilitets-shim (Debian CURL_OPENSSL_4 vs nix CURL_GNUTLS_4).
  sforzando =
    let
      curlShimC = pkgs.writeText "curlshim.c" ''
        #include <stddef.h>
        /* sforzando bruker curl kun til nettverk (oppdateringssjekk), ikke lyd
           -> trygge no-op-stubber, versjonert som CURL_OPENSSL_4. */
        void* curl_easy_init(void){return NULL;}
        long  curl_easy_setopt(void*a,int b,...){return 0;}
        long  curl_easy_perform(void*a){return 1;}
        void  curl_easy_cleanup(void*a){}
        void* curl_mime_init(void*a){return NULL;}
        void* curl_mime_addpart(void*a){return NULL;}
        long  curl_mime_name(void*a,const char*b){return 0;}
        long  curl_mime_data(void*a,const char*b,size_t c){return 0;}
        void  curl_mime_free(void*a){}
      '';
      curlShimMap = pkgs.writeText "curlshim.map" ''
        CURL_OPENSSL_4 {
          global:
            curl_easy_init; curl_easy_setopt; curl_easy_perform; curl_easy_cleanup;
            curl_mime_init; curl_mime_addpart; curl_mime_name; curl_mime_data; curl_mime_free;
          local: *;
        };
      '';
    in
    pkgs.stdenv.mkDerivation rec {
      pname = "sforzando";
      version = "1.982";
      src = pkgs.fetchurl {
        url = "https://sforzando.s3.us-east-1.amazonaws.com/LINUX_plogue-sforzando_${version}_x86_64.zip";
        hash = "sha256-7ms1T9N1/50M4wgZaD9E07cSof5P9Tx35E3wNtqCqQA=";
      };
      nativeBuildInputs = [ pkgs.unzip pkgs.dpkg pkgs.patchelf pkgs.gcc ];
      buildInputs = with pkgs; [
        stdenv.cc.cc.lib pango cairo glib fontconfig zlib libpng
        libxcb libxcb-util libxkbcommon
      ];
      dontStrip = true;
      unpackPhase = ''
        runHook preUnpack
        unzip $src
        runHook postUnpack
      '';
      installPhase = ''
        runHook preInstall
        cd LINUX_plogue-sforzando_${version}_x86_64
        mkdir -p extract
        dpkg-deb -x plogue-aria_${version}_amd64.deb extract
        dpkg-deb -x plogue-sforzando_${version}_amd64.deb extract
        mkdir -p $out/opt $out/vst3
        cp -r extract/opt/Plogue $out/opt/Plogue
        cp -r extract/usr/lib/vst3/sforzando.vst3 $out/vst3/sforzando.vst3
        chmod -R u+w $out
        # curl-kompatibilitets-shim (unikt soname, kolliderer ikke med systemets curl)
        gcc -shared -fPIC -O2 -o $out/opt/Plogue/Aria/libcurl_ariacompat.so \
          ${curlShimC} -Wl,--version-script=${curlShimMap} \
          -Wl,-soname,libcurl_ariacompat.so
        rpath="${lib.makeLibraryPath buildInputs}"
        # motoren: bytt curl-avhengighet til shim; RPATH = $ORIGIN + libs
        patchelf --replace-needed libcurl.so.4 libcurl_ariacompat.so \
          $out/opt/Plogue/Aria/libAria.so
        patchelf --set-rpath '$ORIGIN':"$rpath" $out/opt/Plogue/Aria/libAria.so
        # ARIA-effektene
        for so in $out/opt/Plogue/Aria/Plugins/*.so; do
          patchelf --set-rpath "$rpath" "$so"
        done
        # selve VST3-plugin-en
        patchelf --set-rpath "$rpath" \
          $out/vst3/sforzando.vst3/Contents/x86_64-linux/sforzando.so
        runHook postInstall
      '';
      meta.description = "Plogue sforzando (native Linux VST3), NixOS-patchet";
    };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  # 7.2 (linuxPackages_latest) ga USB-lyd-dropouts paa SSL2 (snd-usb-audio-regresjon?)
  # — tilbake paa standard-LTS til en 7.2.x-fiks er bekreftet.
  boot.extraModulePackages = [ config.boot.kernelPackages.it87 ];
  boot.kernelModules = [ "it87" "ntsync" ];
  boot.extraModprobeConfig = "options it87 ignore_resource_conflict=1";

networking.hostName = "nixos"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
 time.timeZone = "Europe/Oslo";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    keyMap = "no";
  };
  services.xserver.xkb.layout = "no";

  systemd.tmpfiles.rules = [
     "d /mnt/data 0755 benjamin users -"

     # REAPER/sforzando: symlink motor + VST3 fra Nix-store (GC-sikkert),
     # og zenity paa den absolutte stien Plogue-plugins krever for fil-dialog.
     "L+ /opt/Plogue - - - - ${sforzando}/opt/Plogue"
     "L+ /usr/bin/zenity - - - - ${pkgs.zenity}/bin/zenity"
     "d /usr/lib/vst3 0755 root root -"
     "L+ /usr/lib/vst3/sforzando.vst3 - - - - ${sforzando}/vst3/sforzando.vst3"
     "L+ /home/benjamin/.vst3/sforzando.vst3 - - - - ${sforzando}/vst3/sforzando.vst3"
   ];

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


  security.rtkit.enable = true;

  # Sanntids-prioritet for lyd-apper (REAPER m.fl.) — slik at lyd-traaden ikke
  # sultes ut av tunge prosesser som spill. Uten dette er rtprio-grensen 0.
  security.pam.loginLimits = [
    { domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
    { domain = "@audio"; item = "rtprio";  type = "-"; value = "95"; }
  ];

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
    # ENE-kontrollerne paa SMBus svarer ikke alltid paa foerste skann etter boot;
    # restart av openrgb-serveren re-detekterer. Indekser parses dynamisk slik at
    # rekkefoelgen (RAM vs. hovedkort) ikke betyr noe.
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
          alsa_input.usb-Solid_State_Logic_SSL_2__Mk_II-00.HiFi__Mic1__source 140% \
          && exit 0
        sleep 1
      done
      exit 1
    '';
  };

  services.pipewire.extraConfig.pipewire."60-sm57-mono" = {
    "context.modules" = [
      {
        name = "libpipewire-module-loopback";
        args = {
          "capture.props" = {
            "node.name" = "capture.sm57";
            "target.object" = "alsa_input.usb-Solid_State_Logic_SSL_2__Mk_II-00.HiFi__Mic1__source";
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

  services.pipewire.extraConfig.pipewire."99-lowlatency" = {
    "context.properties" = {
      "default.clock.rate" = 48000;
      # USB-vennlig buffer: 128/64 var for aggressivt og ga XRUN-dropouts
      # paa SSL 2+. 512/256 er fortsatt lav latens, men stabilt.
      "default.clock.quantum" = 512;
      "default.clock.min-quantum" = 256;
      "default.clock.max-quantum" = 2048;
    };
  };

  services.pipewire = {
    enable = true;
    jack.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.extraConfig."51-ssl2-names" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              { "device.name" = "alsa_card.usb-Solid_State_Logic_SSL_2__Mk_II-00"; }
            ];
            actions = {
              "update-props" = {
                "device.description" = "SSL 2+ MkII";
              };
            };
          }
          {
            matches = [
              { "node.name" = "alsa_input.usb-Solid_State_Logic_SSL_2__Mk_II-00.HiFi__Mic1__source"; }
            ];
            actions = {
              "update-props" = {
                "node.description" = "SSL 2+ Mic 1";
                "node.nick" = "SSL 2+ Mic 1";
              };
            };
          }
          {
            matches = [
              { "node.name" = "alsa_input.usb-Solid_State_Logic_SSL_2__Mk_II-00.HiFi__Mic2__source"; }
            ];
            actions = {
              "update-props" = {
                "node.description" = "SSL 2+ Mic 2";
                "node.nick" = "SSL 2+ Mic 2";
              };
            };
          }
          {
            matches = [
              { "node.name" = "alsa_output.usb-Solid_State_Logic_SSL_2__Mk_II-00.HiFi__Line1__sink"; }
            ];
            actions = {
              "update-props" = {
                "node.description" = "SSL 2+ Speakers";
                "node.nick" = "SSL 2+ Speakers";
              };
            };
          }
          {
            matches = [
              { "node.name" = "alsa_output.usb-Solid_State_Logic_SSL_2__Mk_II-00.HiFi__Line2__sink"; }
            ];
            actions = {
              "update-props" = {
                "node.description" = "SSL 2+ Line Out 3/4";
                "node.nick" = "SSL 2+ Line Out 3/4";
              };
            };
          }
          {
            matches = [
              { "node.name" = "alsa_input.hw_II_0"; }
            ];
            actions = {
              "update-props" = {
                "node.description" = "SSL 2+ Raw In 8ch";
                "node.nick" = "SSL 2+ Raw In 8ch";
              };
            };
          }
          {
            matches = [
              { "node.name" = "alsa_output.hw_II_0"; }
            ];
            actions = {
              "update-props" = {
                "node.description" = "SSL 2+ Raw Out 6ch";
                "node.nick" = "SSL 2+ Raw Out 6ch";
              };
            };
          }
        ];
    };
  };

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.benjamin = {
     isNormalUser = true;
     extraGroups = [ "wheel" "audio" "docker" ]; # sudo + sanntids-lyd (rtprio) + docker-sokkel
     shell = pkgs.zsh;
     packages = with pkgs; [

       bat
       eza
       delta
       fd
       fzf
       ripgrep
       jq
       yq-go
       fastfetch
       tree-sitter
       gcc
       unzip
       wl-clipboard
       direnv
       zoxide

       nerd-fonts.jetbrains-mono

       go
       lua
       kotlin
       nodejs
       rustup
       gh
       sops
       docker

       tree
       neovim
       zsh
       ghostty
       alacritty
       waybar
       wofi
       yazi
       tmux
       stow
       git
       git-lfs

       spotify
       discord
       reaper
       tuxguitar
       musescore
       freecad
       zapzap           # WhatsApp
       bolt-launcher corectrl neural-amp-modeler-lv2
       # pwvucontrol
       alsa-utils
       blueman
       qalculate-gtk
       udiskie
       claude-code
       opencode

       cosmic-monitor

     ];
   };

  programs.niri.enable = true;
  services.desktopManager.cosmic.enable = true;
  services.displayManager.defaultSession = "cosmic";
  programs.corectrl.enable = true;
  

  programs.appimage = {
    enable = true;
    binfmt = true;
  };
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      libx11
      libXext
      libxrender
      libxtst
      libxi
      libGL
      stdenv.cc.cc.lib
      fontconfig
      freetype
      libpng
      zlib
      bzip2
      brotli
      expat
      alsa-lib
    ];
  };

  security.polkit.enable = true;
  security.sudo.wheelNeedsPassword = false;

  services.displayManager.cosmic-greeter.enable = true;

  hardware.alsa.enablePersistence = true;

  # Komprimert swap i RAM. Maskinen har 32 GB og hadde null swap, som gjorde at
  # minnepress ble en livelock: kjernen kunne bare kaste page cache, lese den inn
  # igjen, og kaste den paa nytt. Hard reset 2026-08-30 18:54 av akkurat dette.
  # Med zram faar kjernen noe aa gjenvinne, og OOM-killeren rekker aa gjoere jobben.
  zramSwap = {
    enable = true;
    memoryPercent = 50;
    algorithm = "zstd";
  };


  boot.kernelParams = [ "nvidia-drm.modeset=1" "acpi_enforce_resources=lax" ];

  # Gjoer stille frys til noe som etterlater spor. pstore + systemd-pstore er
  # allerede paa plass; det som manglet var at kjernen faktisk paniserer.
  #   hung_task_panic: en oppgave blokkert i 120 s utloeser panic i stedet for
  #     bare en logglinje. GPU-hengen 7. sep hadde Xwayland blokkert i 245 s.
  #   panic = 20: reboot automatisk 20 s etter panic, saa maskinen kommer opp
  #     igjen selv. Uten dette blir den staaende med panic paa skjermen.
  boot.kernel.sysctl = {
    "kernel.hung_task_panic" = 1;
    "kernel.panic" = 20;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    powerManagement.enable = true;
  };

  nixpkgs.config.allowUnfree = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";

    # TLS-backend for GIO. WebKitGTK/libsoup gjoer HTTPS gjennom GTlsBackend,
    # som ligger i glib-networking og lastes som GIO-modul - ikke via
    # LD_LIBRARY_PATH. Uten denne feiler all HTTPS i webview-baserte plugins
    # (TONE3000 i REAPER: "couldn't establish a secure connection").
    # Liste, ikke streng: da slaar den seg sammen med dconf/gvfs sine verdier
    # i stedet for aa overskrive dem.
    GIO_EXTRA_MODULES = [ "${pkgs.glib-networking}/lib/gio/modules" ];
  };
  # Lokal Docker-motor. Kreves for Claude Code sin docker-sandkasse:
  # containere maa kjoere lokalt for aa se arbeidskatalogen. Fjerkontekstene
  # (homeserver) ligger fortsatt i ~/.docker og kan velges med docker context use.
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };


  programs.gamescope.enable = true;
  programs.firefox = {
    enable = true;
    preferences = { "general.autoScroll" = true; };
  };

  programs.zsh.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
    extraCompatPackages = [ pkgs.proton-ge-bin ];  # GE-Proton: har winewayland (PROTON_ENABLE_WAYLAND=1)
  };

  # Xbox-kontroller over Bluetooth (bedre driver enn hid-generic)
  hardware.xpadneo.enable = true;

  # Java: jdk25 som standard (java i PATH + JAVA_HOME), og fast sti i
  # /etc/jdks/ for Gradle toolchains og kotlin-lsp (erstatter sdkman)
  programs.java = {
    enable = true;
    package = pkgs.jdk25;
  };
  environment.etc."jdks/25".source = pkgs.jdk25.home;


  programs.xwayland.enable = true;

 # List packages installed in system profile.
 # You can use https://search.nixos.org/ to find more packages (and options).
 environment.systemPackages = with pkgs; [
   vim
   wget
   xwayland-satellite
   bibata-cursors
   lm_sensors
   easyeffects
   deepfilternet
   pipewire.jack

   zenmonitor
   ryzenadj

   yabridge
   yabridgectl
   wineWow64Packages.staging   # samme Wine staging, men WoW64-varianten ligger i binaercachen (den gamle kompileres lokalt)

   zenity          # fil-dialog for Plogue-plugins (sforzando Import)
   # sforzando symlinkes via systemd.tmpfiles (over) -> ikke i systemPackages
   # (unngaar aa lenke /opt og /vst3 inn i systemprofilen)

 ];

 security.wrappers.ryzenadj = {
  source = "${pkgs.ryzenadj}/bin/ryzenadj";
  capabilities = "cap_sys_admin+ep";
  owner = "root";
  group = "root";
 };

 environment.variables = {
  XCURSOR_THEME = "Bibata-Modern-Classic";
  XCURSOR_SIZE = "24";
  GTK_THEME = "Adwaita:dark";
  GTK_IM_MODULE = "simple";
    # NixOS setter EDITOR=nano som standard i /etc/set-environment. Uten disse
    # to fikk du nano i et friskt terminalvindu og nvim inne i tmux.
    EDITOR = "nvim";
    VISUAL = "nvim";
  QT_STYLE_OVERRIDE = "adwaita-dark";
 };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

 services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

}
