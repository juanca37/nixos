{ pkgs,  config, ...}:

{

  ## neovim
  programs.neovim = {
	enable = true;
	viAlias = true;
	vimAlias = true;
};
  home.file.".config/nvim" = {
	source = /${config.home.homeDirectory}/Dotfiles/nvim;
	recursive = true;
};
  home.packages = [pkgs.gcc pkgs.fzf ];
  }
