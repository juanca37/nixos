{ lib, config, pkgs,  inputs, ... }:
{
  home.stateVersion = "23.05"; # Please read the comment before changing.
  programs.home-manager.enable = true;
  imports = [
		./nvim.nix 
		./tmux.nix
		./zsh.nix
		];
  ## Terminal config
  programs.kitty.enable = true;
  programs.kitty.settings = {
background_opacity =  0.6;
dynamic_background_opacity = true; 
};  

  ## Firefox cconfig
  programs.firefox.enable = true;
  programs.firefox.profiles.default.extensions.packages = with inputs.firefox-addons.packages.${pkgs.system}; [ darkreader bitwarden ublock-origin ];
 
  ## Obsidian config
  home.packages = [pkgs.obsidian pkgs.spotify pkgs.slack ];
  # home.activation.makeTrampolineApps = lib.hm.dag.entryAfter [ "writeBoundary" ] (
  #   builtins.readFile ./make-app-trampolines.sh
  # );
}
