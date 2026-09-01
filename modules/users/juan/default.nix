{ config, pkgs, ... }:

{
	home-manager.users.juan = { ... }: {
		home.stateVersion = "24.11";
	
		home.packages = with pkgs; [
			curl
			wget
			tmux
			zsh
			btop
			claude-code
		];

		programs.git = {
			enable = true;
			userName = "juanca37";
			userEmail = "juancarrascoalonso@hotmail.com";
		};
	};
}
