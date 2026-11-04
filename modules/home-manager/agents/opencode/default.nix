{
  config,
  pkgs,
  llm-pkgs,
  lib,
  ...
}:

let
  # OpenCode 2 binary in llm-agents is installed as `opencode2` to allow
  # side-by-side installation with 1.x. We symlink `opencode` to `opencode2`
  # so that both commands work identically in terminal, scripts, and agent-box.
  opencode2Package = pkgs.symlinkJoin {
    name = "opencode-${llm-pkgs.opencode2.version}";
    version = llm-pkgs.opencode2.version;
    paths = [ llm-pkgs.opencode2 ];
    postBuild = ''
      ln -s $out/bin/opencode2 $out/bin/opencode
    '';
    meta = (llm-pkgs.opencode2.meta or { }) // {
      mainProgram = "opencode";
    };
  };

  # Map catppuccin flavor to OpenCode 2's theme name
  catppuccinTheme =
    if config.catppuccin.flavor == "frappe" then
      "catppuccin-frappe"
    else if config.catppuccin.flavor == "macchiato" then
      "catppuccin-macchiato"
    else
      "catppuccin";
in
{
  programs.opencode = {
    enable = true;
    package = lib.mkDefault opencode2Package;

    cli = {
      tabs = {
        mode = "off";
      };
    }
    // lib.optionalAttrs (config.catppuccin.enable or false) {
      theme = {
        name = catppuccinTheme;
      };
    };
  };

  # Disable catppuccin/nix's opencode module until it updates for OpenCode 2
  # (catppuccin/nix still writes to obsolete tui.json which OpenCode 2 ignores)
  catppuccin.opencode.enable = false;
}
