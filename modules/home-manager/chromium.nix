{
  config,
  lib,
  pkgs,
  flake-inputs,
  inputs,
  ...
}:
{
  programs.chromium = {
    enable = true;
    # Note: Extension settings (like Dark Reader theme), default search engine (DuckDuckGo),
    # and privacy settings need to be configured manually within Chromium after installation.
    extensions = [
      {
        id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; # Dark Reader
      }
      {
        id = "dbepggeogbaibhgdmkmvscebcnmaixcl"; # Vimium (for vi-keys)
      }
      {
        id = "fnpgafddgcllljggjdmhcnjhmfgbhchb"; # Quick Search Wiktionary
      }
    ];
  };
}