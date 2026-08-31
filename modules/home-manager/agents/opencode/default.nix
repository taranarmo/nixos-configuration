{
  config,
  pkgs,
  pkgs-small,
  llm-pkgs,
  lib,
  ...
}:

{
  imports = [
    ./google.nix
  ];

  programs.opencode = {
    enable = true;
    package = llm-pkgs.opencode;
  };
}
