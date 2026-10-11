{ config, pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    settings = {
      remember_window_size = false;
    };
  };
  home.sessionVariables = {
    PAGER = "${pkgs.moor}/bin/moor";
    MANPAGER = "${pkgs.moor}/bin/moor";
  };
  programs.ghostty.enable = true;
  programs.wezterm.enable = true;
  programs.bat.enable = true;
}
