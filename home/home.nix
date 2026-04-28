{ config, pkgs, ... }:

{
  imports = [
    ../modules/home-manager/git.nix
    ../modules/home-manager/shell.nix
    ../modules/home-manager/terminals.nix
    ../modules/home-manager/tmux.nix
    ../modules/home-manager/utilities.nix
    ../modules/home-manager/development.nix
    ../modules/home-manager/pdf-viewer.nix
    ../modules/home-manager/hyprland.nix
    ../modules/home-manager/nixvim.nix
    #../modules/home-manager/firefox.nix
    ../modules/home-manager/brave.nix
    ../modules/home-manager/waybar.nix
    ../modules/home-manager/darkman.nix
    ../modules/home-manager/hypridle.nix
    ../modules/home-manager/hyprlock.nix
    ../modules/home-manager/chromium.nix
    ../modules/home-manager/qutebrowser.nix
    ../modules/home-manager/agents
  ];
  home.username = "taranarmo";
  home.homeDirectory = "/home/taranarmo";

  catppuccin = {
    enable = true;
    flavor = "mocha";
  };
  gtk = {
    enable = true;
  };

  # Install fonts via Home Manager
  fonts.fontconfig.enable = true;

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
