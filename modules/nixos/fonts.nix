{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Fonts should be put in separate section of other packages
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    roboto
    font-awesome
    nerd-fonts.arimo
    nerd-fonts.symbols-only
    nerd-fonts.jetbrains-mono
    nerd-fonts.dejavu-sans-mono
  ];
}
