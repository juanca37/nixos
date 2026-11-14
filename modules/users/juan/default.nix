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
			# SSH keys live in GNOME's gcr-ssh-agent (SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gcr/ssh);
			# gpg-agent only handles GPG.
			pinentry.package = pkgs.pinentry-gnome3; # Choose a pinentry flavor matching your desktop env
		};

		programs.git = {
			enable = true;
			settings.user = {
				name = "juanca37";
				email = "juancarrascoalonso@hotmail.com";
			};
		};

		programs.omp = {
			enable = true;
			settings.startup.quiet = true;
		};
	};
}
