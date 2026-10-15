{  pkgs, ...}:
{
	nixpkgs.config.allowUnfree = true;
	home-manager.users.juan = { config, ... }:
	let
		outOfStore = path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/${path}";
	in {
		home.file.".config/niri/config.kdl".source = outOfStore "Projects/Dotfiles/niri/config.kdl";
		home.file.".zshrc".source = outOfStore "Projects/Dotfiles/zsh/.zshrc";
		home.file.".zsh_alias.conf".source = outOfStore "Projects/Dotfiles/zsh/.zsh_alias.conf";
		home.file.".zsh_commands.conf".source = outOfStore "Projects/Dotfiles/zsh/.zsh_commands.conf";
		home.file.".zsh_prompt.conf".source = outOfStore "Projects/Dotfiles/zsh/.zsh_prompt.conf";
		home.file.".zsh_syngenta.conf".source = outOfStore "Projects/Dotfiles/zsh/.zsh_syngenta.conf";
		home.file.".tmux.conf".source = outOfStore "Projects/Dotfiles/tmux/.tmux.conf";
		home.file.".theme.conf".source = outOfStore "Projects/Dotfiles/tmux/.theme.conf";
		home.packages = with pkgs; [
			kitty
			firefox
			slack
			fzf
			zoxide
			eza
			bat
			lazygit
			gh
			neovim
			postman
			bruno
			drawio
			dbeaver-bin
			zoom-us
		];
		programs.vscode = {
			enable = true;
		};
	};
}
