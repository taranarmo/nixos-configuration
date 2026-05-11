{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.custom.notebook = {
    enable = lib.mkEnableOption "notebook power-saving stack (TLP, thermald)";
  };

  config = lib.mkIf config.custom.notebook.enable {
    services.tuned.enable = true;
    services.thermald.enable = true;
  };
}
