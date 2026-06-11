{ config, pkgs, pkgs-small, lib, ... }:

{
  imports = [
    ./opencode
  ];

  home.packages = with pkgs-small; [
    rtk
    antigravity-cli
  ];

  programs.antigravity-cli = {
    enable = true;
    package = pkgs-small.antigravity-cli;
  };

  programs.claude-code = {
    enable = true;
    package = pkgs-small.claude-code;
  };
}
