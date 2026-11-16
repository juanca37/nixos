{ pkgs, ... }:
{
	home-manager.users.juan = {
		# zsh completions come with the packages (NixOS adds profile site-functions to fpath).
		home.packages = with pkgs; [
			kubectl
			kubectx # also provides kubens; interactive picker via fzf when run without arguments
		];

		# Colorized kubectl output. The `kubectl` alias and completion live in Dotfiles' .zsh_alias.conf:
		# this module's enableAlias / zsh integration only write to a Home Manager-managed zsh config.
		programs.kubecolor.enable = true;

		programs.k9s = {
			enable = true;
			settings.k9s = {
				skipLatestRevCheck = true; # updates come from nixpkgs, not k9s' own check
				ui = {
					skin = "gruvbox";
					logoless = true;
					reactive = true; # pick up skin/config edits without restarting k9s
				};
			};

			# Gruvbox dark to match the tmux theme; "default" background keeps kitty's translucency.
			skins.gruvbox = let
				bg = "default";
				bg0 = "#282828";
				bg2 = "#504945";
				gray = "#928374";
				fg = "#ebdbb2";
				fg4 = "#a89984";
				red = "#fb4934";
				green = "#b8bb26";
				yellow = "#fabd2f";
				blue = "#83a598";
				purple = "#d3869b";
				aqua = "#8ec07c";
				orange = "#fe8019";
			in {
				k9s = {
					body = { fgColor = fg; bgColor = bg; logoColor = orange; };
					prompt = { fgColor = fg; bgColor = bg; suggestColor = gray; };
					info = { fgColor = yellow; sectionColor = fg; k9sRevColor = gray; cpuColor = aqua; memColor = blue; };
					help = { fgColor = fg; bgColor = bg; keyColor = yellow; numKeyColor = purple; sectionColor = green; };
					dialog = {
						fgColor = fg;
						bgColor = bg;
						buttonFgColor = bg0;
						buttonBgColor = fg4;
						buttonFocusFgColor = bg0;
						buttonFocusBgColor = yellow;
						labelFgColor = orange;
						fieldFgColor = fg;
					};
					frame = {
						border = { fgColor = bg2; focusColor = aqua; };
						menu = { fgColor = fg4; keyColor = yellow; numKeyColor = purple; };
						crumbs = { fgColor = bg0; bgColor = fg4; activeColor = yellow; };
						status = {
							newColor = aqua;
							modifyColor = blue;
							addColor = green;
							pendingColor = orange;
							errorColor = red;
							highlightColor = yellow;
							killColor = gray;
							completedColor = gray;
						};
						title = { fgColor = fg; bgColor = bg; highlightColor = orange; counterColor = yellow; filterColor = purple; };
					};
					views = {
						charts = { bgColor = bg; defaultDialColors = [ aqua red ]; defaultChartColors = [ aqua red ]; };
						table = {
							fgColor = fg;
							bgColor = bg;
							# k9s fills the selected row with the row's status color; dark text stays readable on all of them.
							cursorFgColor = bg0;
							cursorBgColor = bg2;
							header = { fgColor = fg4; bgColor = bg; sorterColor = orange; };
						};
						xray = { fgColor = fg; bgColor = bg; cursorColor = bg2; graphicColor = blue; showIcons = false; };
						yaml = { keyColor = blue; colonColor = gray; valueColor = fg; };
						logs = {
							fgColor = fg;
							bgColor = bg;
							indicator = { fgColor = fg; bgColor = bg; toggleOnColor = green; toggleOffColor = gray; };
						};
					};
				};
			};
		};
	};
}
