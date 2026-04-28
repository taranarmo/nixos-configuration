{ config, pkgs, pkgs-master, lib, ... }:

{
  imports = [
    ./opencode
  ];

  home.packages = with pkgs; [
    rtk
  ];

  programs.gemini-cli = {
    enable = true;
    package = pkgs-master.gemini-cli;
  };

  programs.claude-code = {
    enable = true;
  };
}
