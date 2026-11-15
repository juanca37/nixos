{ config, pkgs, ... }:

{
	home-manager.users.juan = { lib, ... }: {
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

		programs.omp.enable = true;

		# Not `programs.omp.settings`: that activation `install`s a fresh config.yml,
		# and home-manager-juan.service re-activates on every boot, wiping runtime
		# state (setupVersion → onboarding reruns, model roles, ...). Deep-merge the
		# declared keys into the existing file instead; declared values win.
		home.activation.ompConfigMerge = let
			settings = (pkgs.formats.yaml { }).generate "omp-settings.yml" {
				startup.quiet = true;
				# Custom theme in ~/.omp/agent/themes/: blue background on user messages.
				theme.dark = "titanium-contrast";
			};
		in lib.hm.dag.entryAfter [ "writeBoundary" ] ''
			ompCfg="$HOME/.omp/agent/config.yml"
			run mkdir -p "$HOME/.omp/agent"
			if [ -f "$ompCfg" ]; then
				run ${pkgs.yq-go}/bin/yq -i '. *= load("${settings}")' "$ompCfg"
			else
				run install -m 600 ${settings} "$ompCfg"
			fi
		'';
	};
}
