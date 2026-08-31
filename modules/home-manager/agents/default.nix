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
    ./opencode
  ];

  home.packages = [
    llm-pkgs.rtk
  ];

  programs.antigravity-cli = {
    enable = true;
    package = llm-pkgs.antigravity-cli;
  };

  programs.claude-code = {
    enable = true;
    package = llm-pkgs.claude-code;
  };
}
