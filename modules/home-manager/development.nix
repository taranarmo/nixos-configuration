{ config, pkgs, pkgs-small, ... }:

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
      h5py
      plotly
      scikit-learn
      jupytext
      jupyter
      boto3
      duckdb
    ]))
    julia
    postgresql
    uv
    duckdb
  ];

  # File type settings
  programs.git = {
    enable = true;
  };
}
