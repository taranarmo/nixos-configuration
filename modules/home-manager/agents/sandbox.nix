{
  config,
  lib,
  pkgs,
  ...
}:

let
  agentBox = pkgs.writeShellApplication {
    name = "agent-box";
    runtimeInputs = with pkgs; [
      bubblewrap
      coreutils
      gnugrep
    ];
    text = builtins.readFile ./agent-box.sh;
  };

  agentSandboxAlias = pkgs.runCommand "agent-sandbox-alias" { } ''
    mkdir -p $out/bin
    ln -s ${agentBox}/bin/agent-box $out/bin/agent-sandbox
  '';
in
{
  home.packages = [
    agentBox
    agentSandboxAlias
  ];
}
