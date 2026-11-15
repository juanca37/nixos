{  pkgs, ...}:
{
	nixpkgs.config.allowUnfree = true;
	home-manager.users.juan = { config, ... }:
	let
		outOfStore = path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/${path}";
	in {
		home.file.".zshrc".source = outOfStore "Projects/Dotfiles/zsh/.zshrc";
		home.file.".zsh_alias.conf".source = outOfStore "Projects/Dotfiles/zsh/.zsh_alias.conf";
		home.file.".zsh_commands.conf".source = outOfStore "Projects/Dotfiles/zsh/.zsh_commands.conf";
		home.file.".zsh_prompt.conf".source = outOfStore "Projects/Dotfiles/zsh/.zsh_prompt.conf";
		home.file.".zsh_syngenta.conf".source = outOfStore "Projects/Dotfiles/zsh/.zsh_syngenta.conf";
		home.file.".tmux.conf".source = outOfStore "Projects/Dotfiles/tmux/.tmux.conf";
		home.file.".theme.conf".source = outOfStore "Projects/Dotfiles/tmux/.theme.conf";
		xdg.configFile."niri/config.kdl".source = outOfStore "Projects/Dotfiles/niri/config.kdl";
		xdg.configFile."noctalia/config.toml".source = outOfStore "Projects/Dotfiles/noctalia/config.toml";
		# Nix-provided tmux plugins; sourced (quietly) from the Dotfiles .tmux.conf.
		home.file.".tmux-plugins.conf".text = let
			tmuxFzfWindowSwitch = pkgs.writeShellScript "tmux-fzf-window-switch" ''
				export TMUX_FZF_BIN="${pkgs.tmuxPlugins.tmux-fzf}/share/tmux-plugins/tmux-fzf/scripts/.fzf-tmux"
				source "${pkgs.tmuxPlugins.tmux-fzf}/share/tmux-plugins/tmux-fzf/scripts/.envs"
				if [[ -z "$TMUX_FZF_WINDOW_FORMAT" ]]; then
					windows=$(tmux list-windows -a)
				else
					windows=$(tmux list-windows -a -F "#S:#{window_index}: $TMUX_FZF_WINDOW_FORMAT")
				fi
				FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --header='Select target window.'"
				target_origin=$(printf "%s\n[cancel]" "$windows" | eval "$TMUX_FZF_BIN $TMUX_FZF_OPTIONS $TMUX_FZF_PREVIEW_OPTIONS")
				[[ "$target_origin" == "[cancel]" || -z "$target_origin" ]] && exit
				target=$(echo "$target_origin" | sed 's/: .*//')
				echo "$target" | sed 's/:.*//g' | xargs -I{} tmux switch-client -t {}
				echo "$target" | xargs -I{} tmux select-window -t {}
			'';
		in ''
			bind w run-shell -b "${tmuxFzfWindowSwitch}"
			run-shell ${pkgs.tmuxPlugins.tmux-fzf.rtp}
			run-shell ${pkgs.tmuxPlugins.resurrect.rtp}
			run-shell ${pkgs.tmuxPlugins.continuum.rtp}
		'';
		home.packages = with pkgs; [
			kitty
			claude-desktop
			firefox
			fzf
			zoxide
			eza
			bat
			lazygit
			gh
			neovim
		] ++ (with pkgs.latest; [
			# Fast-moving apps: updated with `nix flake update nixpkgs-latest`
			slack
			postman
			bruno
			drawio
			dbeaver-bin
			zoom-us
		]);
		programs.vscode = {
			enable = true;
			package = pkgs.latest.vscode;
		};
	};
}
