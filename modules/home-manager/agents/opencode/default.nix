{
  config,
  pkgs,
  pkgs-small,
  llm-pkgs,
  lib,
  ...
}:

{
  programs.opencode = {
    enable = true;
    package = llm-pkgs.opencode2;
  };
}
