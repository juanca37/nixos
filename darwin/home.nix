{ lib, config, pkgs, inputs,  ... }:
{
  home.stateVersion = "23.05"; # Please read the comment before changing.
  programs.home-manager.enable = true;
  programs.kitty.enable = true;
  programs.firefox = {
  	enable = true;
	profiles.default.extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
  		bitwarden-password-manager
	];
			
};


  home.activation.makeTrampolineApps = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    builtins.readFile ./make-app-trampolines.sh
  );

}
