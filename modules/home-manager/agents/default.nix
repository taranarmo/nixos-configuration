{ config, pkgs, pkgs-small, lib, ... }:

{
  imports = [
    ./opencode
  ];

  home.packages = with pkgs; [
    rtk
  ];

  programs.gemini-cli = {
    enable = true;
    package = pkgs-small.gemini-cli;
  };

  programs.claude-code = {
    enable = true;
  };
}
