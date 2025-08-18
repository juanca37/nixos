{config, ...}:

{

  home.file.".zshrc".source = /${config.home.homeDirectory}/Dotfiles/zsh/.zshrc; 
  home.file.".zsh_alias.conf".source = /${config.home.homeDirectory}/Dotfiles/zsh/.zsh_alias.conf; 
  home.file.".zsh_commands.conf".source = /${config.home.homeDirectory}/Dotfiles/zsh/.zsh_commands.conf; 
  home.file.".zsh_prompt.conf".source = /${config.home.homeDirectory}/Dotfiles/zsh/.zsh_prompt.conf; 

  programs.eza.enable = true;

  programs.lazygit.enable = true;
}
