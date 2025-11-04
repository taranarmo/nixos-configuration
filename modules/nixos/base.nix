{
  config,
  lib,
  pkgs,
  ...
}:

{
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  # Base system packages
  environment.systemPackages = with pkgs; [
    vim-full
    wget
    brightnessctl
    pulseaudio
    pavucontrol
    helvum
    bluez
    gnupg
    rclone
    wl-clipboard
    gcc
    unzip
    cmake
    gnumake
    jq
    qrencode
    (pass.withExtensions (
      ps: with ps; [
        pass-otp
        pass-update
        pass-file
      ]
    ))
    dmenu-wayland
    ydotool
    linuxPackages.v4l2loopback
    v4l-utils
    cachix
  ];
  environment.variables = {
    EDITOR = "vim";
    XDG_SESSION_TYPE = "wayland";
    NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt"; # temp solution for SSL/SSH issue with determinate nix
  };

  programs.screen.enable = true;

  security.polkit.enable = true;

  catppuccin = {
    enable = true;
    flavor = "mocha";
  };
  stylix.autoEnable = true;
}
