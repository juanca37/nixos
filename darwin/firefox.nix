{ inputs, pkgs, ... }:

{

  ## Firefox cconfig
  programs.firefox.enable = true;
  programs.firefox.profiles.default.extensions.packages = with inputs.firefox-addons.packages.${pkgs.system}; [ darkreader bitwarden ublock-origin ];
} 
