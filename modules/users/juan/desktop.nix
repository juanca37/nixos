{  pkgs, ...}:
{
	nixpkgs.config.allowUnfree = true;
	home-manager.users.juan = { config, ... }: {
		home.file.".config/niri/config.kdl".source = /${config.home.homeDirectory}/Projects/Dotfiles/niri/config.kdl;
		home.packages = with pkgs; [
			kitty
			firefox
			slack
		];
		programs.vscode = {
			enable = true;
		};
	};
}
