{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Python packages in system environment
  environment.systemPackages = with pkgs; [
    (python3.withPackages (
      ps: with ps; [
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
      ]
    ))
    postgresql
  ];
}
