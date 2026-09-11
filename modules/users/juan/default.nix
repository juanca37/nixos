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
			awscli2
			ssm-session-manager-plugin
			redis
			uv
		];

		programs.gpg = {
			enable = true;
		};

		services.gpg-agent = {
			enable = true;
			enableSshSupport = true;
			pinentryPackage = pkgs.pinentry-gnome3; # Choose a pinentry flavor matching your desktop env
		};

		programs.git = {
			enable = true;
			userName = "juanca37";
			userEmail = "juancarrascoalonso@hotmail.com";
		};
	};
}
