{ lib, config, pkgs,  inputs, ... }:
{
  home.stateVersion = "23.05"; # Please read the comment before changing.
  programs.home-manager.enable = true;
  programs.kitty.enable = true;
  programs.firefox.enable = true;
  programs.firefox.profiles.default.extensions.packages = with inputs.firefox-addons.packages.${pkgs.system}; [ darkreader bitwarden ublock-origin ];
  
  home.activation.makeTrampolineApps = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    builtins.readFile ./make-app-trampolines.sh
  );
}
