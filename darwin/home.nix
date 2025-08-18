{ lib, config, pkgs,  inputs, ... }:
{
  home.stateVersion = "23.05"; # Please read the comment before changing.
  programs.home-manager.enable = true;
  imports = [
		./nvim.nix 
		./tmux.nix
		./zsh.nix
		./kitty.nix
		./firefox.nix
		];
  ## Obsidian config
  home.packages = [pkgs.obsidian pkgs.spotify pkgs.slack ];
  # home.activation.makeTrampolineApps = lib.hm.dag.entryAfter [ "writeBoundary" ] (
  #   builtins.readFile ./make-app-trampolines.sh
  # );
}
