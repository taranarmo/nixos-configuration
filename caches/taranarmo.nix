{
  nix.settings = {
    substituters = [
      "https://taranarmo.cachix.org?priority=3"
    ];
    trusted-public-keys = [
      "taranarmo.cachix.org-1:g2roO5a/uAPyFpOqiiifskYbqc+yLZHYsnlUrhNLI9k="
    ];
  };
}
