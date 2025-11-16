{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Enable CUDA support for packages
  nixpkgs.config.cudaSupport = true;
  nixpkgs.config.allowUnfreePredicate = 
    p:
    builtins.all (
      license:
      license.free
      || builtins.elem license.shortName [
        "CUDA EULA"
        "cuDNN EULA"
        "cuTENSOR EULA"
        "NVidia OptiX EULA"
      ]
    ) (if builtins.isList p.meta.license then p.meta.license else [ p.meta.license ]);
}