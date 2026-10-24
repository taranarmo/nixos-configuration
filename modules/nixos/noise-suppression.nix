# PipeWire RNNoise microphone noise suppression.
#
# Creates a virtual "Noise Canceling source" built from the hardware mic.
# Applications can select it instead of the raw microphone, while the
# hardware source stays untouched (so per-app choice / toggling is free).
# Adapted from the stock example shipped in `pipewire/share/pipewire/filter-chain/source-rnnoise.conf`.
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # `rnnoise-plugin` (werman/noise-suppression-for-voice) is the package that
  # actually ships the LADSPA plugin (`librnnoise_ladspa.so`), unlike plain
  # `rnnoise`. Its plugins are split into dedicated outputs, so point PipeWire
  # at the `ladspa` output specifically; this option links it into
  # `LADSPA_PATH` of the pipewire user service automatically.
  services.pipewire.extraLadspaPackages = [ pkgs.rnnoise-plugin.ladspa ];

  services.pipewire.extraConfig.pipewire."90-noise-cancel-source" = {
    "context.modules" = [
      {
        name = "libpipewire-module-filter-chain";
        flags = [ "nofail" ];
        args = {
          "node.description" = "Noise Canceling source";
          "media.name" = "Noise Canceling source";
          "filter.graph" = {
            "nodes" = [
              {
                "type" = "ladspa";
                "name" = "rnnoise";
                "plugin" = "librnnoise_ladspa";
                "label" = "noise_suppressor_stereo";
                "control" = {
                  "VAD Threshold (%)" = 50.0;
                };
              }
            ];
          };
          "audio.position" = [
            "FL"
            "FR"
          ];
          "capture.props" = {
            "node.name" = "effect_input.rnnoise";
            "node.passive" = true;
          };
          "playback.props" = {
            "node.name" = "effect_output.rnnoise";
            "media.class" = "Audio/Source";
          };
        };
      }
    ];
  };
}
