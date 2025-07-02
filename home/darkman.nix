{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    gnome-themes-extra
    adwaita-icon-theme
    adwaita-qt
  ];
  services.darkman = {
    enable = true;
    settings = {
      latitude = 52.52; # Berlin latitude
      longitude = 13.405; # Berlin longitude
      usegeoclue = true; # Use geoclue for automatic location if available
      portal = true; # Enable darkman portal for xdg-desktop-portal
    };
  };

  # Make sure xdg-desktop-portal-darkman is installed and used
  xdg.portal = {
    enable = true;
  };

  # Set GTK theme to follow darkman
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita";
      package = pkgs.gnome-themes-extra;
    };
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
  };

#  # Set QT theme to follow darkman
#  qt = {
#    enable = true;
#    #platformTheme = "xdgdesktopportal";
#    style = {
#      name = "adwaita-dark";
#      package = pkgs.adwaita-qt;
#    };
#  };
}
