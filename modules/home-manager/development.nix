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
      boto3
      plotly
      scikit-learn
      torch
      tensorflow
      xgboost
      keras
      nltk
      jupytext
      jupyter
    ]))
    postgresql
    uv
  ];

  # File type settings
  programs.git = {
    enable = true;
  };
}
