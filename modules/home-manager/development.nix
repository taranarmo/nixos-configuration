{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Create a custom Python environment with required packages including Jupyter
    (python3.withPackages (ps: with ps; [
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
      plotly
      scikit-learn
      jupytext
      jupyter
    ]))
    postgresql
    uv
    duckdb
  ];

  # File type settings
  programs.git = {
    enable = true;
  };
}
