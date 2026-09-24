{  pkgs, ...}:
{
	nixpkgs.config.allowUnfree = true;
	home-manager.users.juan = { config, ... }: {
		home.file.".config/niri/config.kdl".source = /${config.home.homeDirectory}/Projects/Dotfiles/niri/config.kdl;
		home.file.".zshrc".source = /${config.home.homeDirectory}/Projects/Dotfiles/zsh/.zshrc;
		home.file.".zsh_alias.conf".source = /${config.home.homeDirectory}/Projects/Dotfiles/zsh/.zsh_alias.conf;
		home.file.".zsh_commands.conf".source = /${config.home.homeDirectory}/Projects/Dotfiles/zsh/.zsh_commands.conf;
		home.file.".zsh_prompt.conf".source = /${config.home.homeDirectory}/Projects/Dotfiles/zsh/.zsh_prompt.conf;
		home.file.".zsh_syngenta.conf".source = /${config.home.homeDirectory}/Projects/Dotfiles/zsh/.zsh_syngenta.conf;
		home.file.".tmux.conf".source = /${config.home.homeDirectory}/Projects/Dotfiles/tmux/.tmux.conf;
		home.file.".theme.conf".source = /${config.home.homeDirectory}/Projects/Dotfiles/tmux/.theme.conf;
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
		];
		programs.vscode = {
			enable = true;
		};
	};
}
