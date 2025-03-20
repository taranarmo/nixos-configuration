{ config, lib, pkgs, inputs, flake-inputs, ... }:

{
  nixpkgs.overlays = [
    flake-inputs.nurpkgs.overlays.default
  ];

  nix = {
    package = pkgs.nixVersions.latest;
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "taranarmo" ];
    };
    gc = {
      automatic = true;
      dates = "Thu";
      options = "--delete-older-than 30d";
    };
  };
  imports =
   [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.tmp.cleanOnBoot = true;
  systemd.tmpfiles.rules = [
    "d /tmp/screenshots 1777 -"
  ];

  networking = {
    hostName = "nixos-ideapad";
    firewall = {
      enable = true;
      #package = pkgs.nftables;
      trustedInterfaces = [ "docker0" ];
      allowedTCPPorts = [ 22 80 443 ]; # Enable ssh, http, https
      checkReversePath = false;
    };
    nat = {
      enable = true;
      internalInterfaces = ["ve-+"];
      externalInterface = "eth0";
    };
    nameservers = [ "127.0.0.1" "::1" "1.1.1.1" "8.8.8.8" ];
    networkmanager = {
      enable = true;
      dns = "none";
      unmanaged = [ "interface-name:ve-*"];
    };
  };

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      AllowUsers = null;
      UseDns = true;
      X11Forwarding = false;
    };
  };

  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      ipv6_servers = true;
      require_dnssec = true;

      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };
      # You can choose a specific set of servers from https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v3/public-resolvers.md
      # server_names = [ ... ];
    };
  };

  systemd.services.dnscrypt-proxy2.serviceConfig = {
    StateDirectory = "dnscrypt-proxy";
  };

  time.timeZone = "Europe/Berlin";

  i18n = {
    defaultLocale = "en_DK.UTF-8";
    extraLocaleSettings = {
      LC_LANG  = "en_DK.UTF-8";
      LC_ADDRESS = "en_DK.UTF-8";
      LC_IDENTIFICATION = "en_DK.UTF-8";
      LC_MEASUREMENT = "en_DK.UTF-8";
      LC_MONETARY = "en_DK.UTF-8";
      LC_NAME = "en_DK.UTF-8";
      LC_NUMERIC = "en_DK.UTF-8";
      LC_PAPER = "en_DK.UTF-8";
      LC_TELEPHONE = "en_DK.UTF-8";
      LC_TIME = "en_DK.UTF-8";
    };
  };

  services.xserver = {
    enable = true;
    xkb.layout = "eu,ru";
    xkb.variant = ",";
    xkb.options = "grp:caps_switch,grp:lalt_lshift_toggle,lv3:ralt_switch,compose:lwin-altgr,compose:rctrl-altgr";
  };
  services.displayManager.sddm = {
    enable = true;
    package = pkgs.kdePackages.sddm;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.avahi.enable = true; # runs the Avahi daemon
  services.avahi.nssmdns4 = true; # enables the mDNS NSS plug-in
  services.avahi.openFirewall = true; # opens the firewall for UDP port 5353

  hardware.enableAllFirmware = true;

  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        FastConnectable = true;
      };
      GATT = {
        ReconnectIntervals = "1. 2. 3";
      };
      Policy = {
        ReconnectAttempts = 7;
      };
    };
  };
  services.blueman.enable = true;

  # MTP mount service
  services.gvfs.enable = true;

  # xdg-desktop-portal works by exposing a series of D-Bus interfaces
  # known as portals under a well-known name
  # (org.freedesktop.portal.Desktop) and object path
  # (/org/freedesktop/portal/desktop).
  # The portal interfaces include APIs for file access, opening URIs,
  # printing and others.
  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    defaultUserShell = pkgs.zsh;

    users.taranarmo = {
      isNormalUser = true;
      description = "Sergey Volkov";
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [
        firefox-wayland
        qutebrowser
        chromium
        lynx
        mpd
        mpc-cli
        gimp
        taskwarrior3
        telegram-desktop
        apvlv
        libnotify
        mpv
        aspell
        aspellDicts.en
        aspellDicts.de
        aspellDicts.ru
        AusweisApp2
        htop-vim
        hurl
      ];
    };
  };

  # Fonts should be put in separate section of other packages
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    roboto
    font-awesome
    nerdfonts
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    vim-full
    #vimPlugins.markdown-preview-nvim
    wget
    brightnessctl
    pulseaudio
    pavucontrol
    helvum
    bluez
    gnupg
    pinentry
    rclone
    tmux
    screen
    wl-clipboard
    gcc
    unzip
    cmake
    gnumake
    jq
    qrencode
    (python3.withPackages(ps: with ps; [
      numpy
      pandas
      scipy
      requests
      matplotlib
      ipython
      hickle
      h5py
      boto3
    ]))
    julia
    (pass.withExtensions(ps: with ps; [ pass-otp pass-update ]))
    libreoffice-qt
    linuxPackages.v4l2loopback
    v4l-utils
    cachix
  ];
  environment.variables = {
    EDITOR = "vim";
    XDG_SESSION_TYPE = "wayland";
  };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.nix-ld.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-tty;
  };
  programs.zsh = {
    enable = true;
  };

  security.polkit.enable = true;
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # so that gtk works properly
    extraPackages = with pkgs; [
      swaylock
      swayidle
      waybar
      swaykbdd # remember keyboard layout per window
      wf-recorder
      wdisplays
      mako # notification daemon
      grim # screenshots
      sway-contrib.grimshot # screenshot helper
      slurp # screen area selector
     #kanshi
      zathura # PDF viewer
      alacritty # Alacritty is the default terminal in the config
      bemenu
      wofi
      swaynotificationcenter
      nwg-bar
    ];
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
    '';
  };
  # programs.waybar.enable = true;
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  # List services that you want to enable:

  services.pcscd.enable = true;
  services.fwupd.enable = true;
  services.logind.lidSwitchDocked = "suspend-then-hibernate";

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
    SuspendState=mem
  '';
  # SuspendState=freeze

  catppuccin = {
    enable = true;
    flavor = "mocha";
  };
  stylix.autoEnable = true;


  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  virtualisation = {
    docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
      extraOptions = "--iptables=False";
    };
    podman = {
      enable = true;
      # Create a `docker` alias for podman, to use it as a drop-in replacement
      #dockerCompat = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
      extraPackages = with pkgs; [
        podman-compose
      ];
    };
    oci-containers = {
      backend = "podman";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
