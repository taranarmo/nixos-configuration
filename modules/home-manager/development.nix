{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Python environment
    (python3.withPackages(ps: with ps; [
      numpy
      pandas
      scipy
      statsmodels
      requests
      matplotlib
      seaborn
      ipython
      hickle
      h5py
      boto3
      plotly
      scikit-learn
      catppuccin
    ]))
    postgresql
    # Python language server for vim
    python3Packages.jedi-language-server
  ];

  # File type settings
  programs.git = {
    enable = true;
  };
}