{ config, pkgs, ... }:

{
  programs.kitty.enable = true;
  home.sessionVariables = {
    PAGER = "${pkgs.moor}/bin/moor";
    MANPAGER = "${pkgs.moor}/bin/moor";
  };
  programs.ghostty.enable = true;
  programs.wezterm.enable = true;
  programs.bat.enable = true;
}
