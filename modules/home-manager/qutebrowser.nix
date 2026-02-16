{ config, pkgs, lib, ... }:

let
  cfg = config.programs.qutebrowser;
  
  # Define Catppuccin color palettes
  catppuccinColors = {
    mocha = {
      base = "#1e1e2e";
      text = "#cdd6f4";
      overlay0 = "#6c7086";
      crust = "#000000";
      blue = "#89b4fa";
      mauve = "#cba6f7";
    };
    frappe = {
      base = "#303446";
      text = "#c6d0f5";
      overlay0 = "#737994";
      crust = "#232634";
      blue = "#8caaee";
      mauve = "#ca9ee6";
    };
    macchiato = {
      base = "#24273a";
      text = "#cad3f5";
      overlay0 = "#6e738d";
      crust = "#181926";
      blue = "#8aadf4";
      mauve = "#c6a0f6";
    };
    latte = {
      base = "#eff1f5";
      text = "#4c4f69";
      overlay0 = "#9ca0b0";
      crust = "#dce0e8";
      blue = "#1e66f5";
      mauve = "#8839ef";
    };
  };

  # Get the selected flavor from the catppuccin config
  selectedFlavor = config.catppuccin.flavor or "mocha";
  colors = catppuccinColors.${selectedFlavor} or catppuccinColors.mocha;
  
  darkReaderCSS = pkgs.writeText "dark-reader.css" ''
    /* Dark Reader-like CSS for qutebrowser with Catppuccin ${selectedFlavor} palette */

    /* Base colors - highest priority */
    html, html * {
      background-color: ${colors.base} !important;
      color: ${colors.text} !important;
    }

    /* Form elements with darker background */
    html input, html textarea, html select, html button, html button *, html input *, html select *, html textarea * {
      background-color: ${colors.crust} !important;
      color: ${colors.text} !important;
    }

    /* Links */
    html a:link { color: ${colors.blue} !important; }
    html a:visited { color: ${colors.mauve} !important; }
    html a:hover { color: ${colors.text} !important; }

    /* Code blocks */
    html pre, html code, html kbd, html samp {
      background-color: ${colors.crust} !important;
    }

    /* Tables */
    html table {
      background-color: ${colors.base} !important;
    }
    html th {
      background-color: ${colors.crust} !important;
    }
    html tr:nth-child(even) {
      background-color: ${colors.overlay0} !important;
    }

    /* Images and media - keep original colors but ensure transparent background */
    html img, html video, html picture, html canvas, html svg, html iframe, html embed, html object {
      background-color: transparent !important;
    }

    /* Override all inline styles */
    html [style], html [style] * {
      background-color: ${colors.base} !important;
      color: ${colors.text} !important;
    }
    html [style*="background"], html [style*="background"] * {
      background-color: ${colors.base} !important;
    }
    html button[style], html button[style] * {
      background-color: ${colors.crust} !important;
    }
  '';

in
{
  programs.qutebrowser = {
    enable = true;

    # Add custom CSS for dark mode similar to Dark Reader
    extraConfig = ''
      config.set("content.user_stylesheets", ["${darkReaderCSS}"])
    '';

    settings = {
      colors.webpage.bg = "transparent";
    };
  };
}
