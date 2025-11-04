{ config, pkgs, ... }:

{
  programs.kitty.enable = true;
  programs.alacritty.enable = true;
  programs.ghostty.enable = true;
  programs.wezterm.enable = true;
  programs.bat.enable = true;
}