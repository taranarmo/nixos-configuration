{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Fonts should be put in separate section of other packages
  fonts.packages =
    with pkgs;
    [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf
      roboto
      font-awesome
    ]
    ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts); # should be redone to list of specific fonts
}
