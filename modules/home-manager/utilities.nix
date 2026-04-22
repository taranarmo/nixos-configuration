{ config, pkgs, pkgs-master, ... }:

{
  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [

    fastfetch

    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    gojq
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processer https://github.com/mikefarah/yq
    moor

    # networking tools
    iperf3
    dnsutils # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc # it is a calculator for the IPv4/v6 addresses

    # misc

    # misc
    cowsay
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    bashmount
    libreoffice-fresh
    marp-cli # slides in Markdown
    at # run command at specified time

    # clouds
    terraform
    awscli2
    aws-vault
    ssm-session-manager-plugin # aws session manager plugin

    # nix related
    nix-search-cli
    nixpkgs-review
    nix-forecast
    nix-update
    nixfmt-tree

    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    # productivity
    hugo # static site generator
    glow # markdown previewer in terminal

    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb

    sqlite
  ];

  programs.btop.enable = true;
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
  };
  programs.fzf.enable = true;
  programs.gh.enable = true;
  programs.nnn.enable = true;
  programs.aria2.enable = true;
  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;
  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (ps: [
      ps.pass-otp
      ps.pass-update
      ps.pass-file
    ]);
  };
  programs.gemini-cli = {
    enable = true;
    package = pkgs-master.gemini-cli;
  };
  programs.claude-code.enable = true;
}
