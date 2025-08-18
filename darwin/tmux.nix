{config, ...}:

{

  programs.tmux.enable = true;
  home.file.".theme.conf".source = /${config.home.homeDirectory}/Dotfiles/tmux/.theme.conf; 
  home.file.".tmux.conf".source = /${config.home.homeDirectory}/Dotfiles/tmux/.tmux.conf; 
}
