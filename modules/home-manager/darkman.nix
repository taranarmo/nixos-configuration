{ config, pkgs, ... }:
{
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
    gtk4.theme = config.gtk.theme;
  };

}
