{ config, pkgs, lib, ... }:

{
  imports = [
    ./qwen.nix
    ./google.nix
  ];

  programs.opencode = {
    enable = true;
  };
}
