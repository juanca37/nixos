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
		# tmux mouse behaviour; sourced (quietly) from the Dotfiles .tmux.conf.
		# 1. Selecting text copies it without leaving copy mode, so the view doesn't jump to the bottom.
		# 2. Copy mode entered with the mouse (wheel or drag) switches the client to the "scroll" key
		#    table: typing there leaves copy mode and sends the key to the app (like a plain terminal),
		#    Esc / C-c only leave. Keys not bound in "scroll" fall back to tmux's normal tables, so
		#    copy mode entered from the keyboard (prefix [) keeps its vi keys.
		home.file.".tmux-mouse.conf".text = let
			inherit (pkgs) lib;
			printable = lib.stringToCharacters "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";
			quoteKey = c: if c == "'" then "\"'\"" else "'${c}'";
			# send-keys without arguments re-sends the key that triggered the binding.
			typeThrough = key: "bind -T scroll ${key} { if -F '#{pane_in_mode}' { send-keys -X cancel } ; send-keys }";
		in ''
			bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-no-clear
			bind -T copy-mode-vi DoubleClick1Pane { select-pane ; send-keys -X select-word ; run-shell -d 0.3 ; send-keys -X copy-pipe-no-clear }
			bind -T copy-mode-vi TripleClick1Pane { select-pane ; send-keys -X select-line ; run-shell -d 0.3 ; send-keys -X copy-pipe-no-clear }

			# Entering copy mode with the mouse (tmux defaults plus the switch to "scroll").
			bind -n WheelUpPane if -F '#{||:#{alternate_on},#{pane_in_mode},#{mouse_any_flag}}' { send-keys -M } { copy-mode -e ; switch-client -T scroll }
			bind -n MouseDrag1Pane if -F '#{||:#{pane_in_mode},#{mouse_any_flag}}' { send-keys -M } { copy-mode -M ; switch-client -T scroll }

			# Mouse inside "scroll": copy-mode-vi behaviour, staying in "scroll" while the pane is in copy
			# mode; on a pane that isn't, the root-table behaviour.
			bind -T scroll WheelUpPane if -F '#{pane_in_mode}' { select-pane ; send-keys -X -N 5 scroll-up ; switch-client -T scroll } { if -F '#{||:#{alternate_on},#{mouse_any_flag}}' { send-keys -M } { copy-mode -e ; switch-client -T scroll } }
			bind -T scroll WheelDownPane if -F '#{pane_in_mode}' { select-pane ; send-keys -X -N 5 scroll-down ; if -F '#{pane_in_mode}' { switch-client -T scroll } } { send-keys -M }
			bind -T scroll MouseDown1Pane { select-pane -t = ; if -F '#{pane_in_mode}' { switch-client -T scroll } { send-keys -M } }
			bind -T scroll MouseUp1Pane if -F '#{pane_in_mode}' { switch-client -T scroll } { send-keys -M }
			bind -T scroll MouseDrag1Pane if -F '#{pane_in_mode}' { select-pane ; send-keys -X begin-selection ; switch-client -T scroll } { if -F '#{mouse_any_flag}' { send-keys -M } { copy-mode -M ; switch-client -T scroll } }
			bind -T scroll MouseDragEnd1Pane if -F '#{pane_in_mode}' { send-keys -X copy-pipe-no-clear ; switch-client -T scroll } { send-keys -M }
			bind -T scroll DoubleClick1Pane if -F '#{pane_in_mode}' { switch-client -T scroll ; select-pane ; send-keys -X select-word ; run-shell -d 0.3 ; send-keys -X copy-pipe-no-clear } { select-pane -t = ; if -F '#{mouse_any_flag}' { send-keys -M } { copy-mode -H ; send-keys -X select-word ; run-shell -d 0.3 ; send-keys -X copy-pipe-and-cancel } }
			bind -T scroll TripleClick1Pane if -F '#{pane_in_mode}' { switch-client -T scroll ; select-pane ; send-keys -X select-line ; run-shell -d 0.3 ; send-keys -X copy-pipe-no-clear } { select-pane -t = ; if -F '#{mouse_any_flag}' { send-keys -M } { copy-mode -H ; send-keys -X select-line ; run-shell -d 0.3 ; send-keys -X copy-pipe-and-cancel } }

			# Keyboard inside "scroll".
			bind -T scroll Escape if -F '#{pane_in_mode}' { send-keys -X cancel }
			bind -T scroll C-c if -F '#{pane_in_mode}' { send-keys -X cancel }
			${lib.concatMapStringsSep "\n" (key: "bind -T scroll ${key} { send-keys ; if -F '#{pane_in_mode}' { switch-client -T scroll } }") [ "Up" "Down" "PPage" "NPage" ]}
			${lib.concatMapStringsSep "\n" typeThrough ([ "Space" "BSpace" "Enter" "Tab" ] ++ map quoteKey printable)}
		'';
		home.packages = with pkgs; [
			kitty
			claude-desktop
			firefox
			fzf
			zoxide
			eza
			bat
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
		# Screenshot annotation (arrows, boxes, blur, text). Super+Shift+S in niri pipes a
		# Noctalia region capture into it: Enter copies and closes, Ctrl+S saves and closes.
		programs.satty = {
			enable = true;
			settings.general = {
				early-exit = true;
				initial-tool = "arrow";
				actions-on-enter = [ "save-to-clipboard" ];
				# wl-copy keeps the image in the clipboard after satty exits.
				copy-command = "${pkgs.wl-clipboard}/bin/wl-copy";
				output-filename = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S annotated.png";
			};
		};
	};
}
