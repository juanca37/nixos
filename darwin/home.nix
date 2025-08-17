{ lib, config, pkgs,  inputs, ... }:
{
  home.stateVersion = "23.05"; # Please read the comment before changing.
  programs.home-manager.enable = true;

  ## Terminal config
  programs.kitty.enable = true;
  programs.kitty.settings = {
background_opacity =  0.6;
dynamic_background_opacity = true; 
};  
  programs.tmux.enable = true;
  home.file.".theme.conf".source = /${config.home.homeDirectory}/Dotfiles/tmux/.theme.conf; 
  home.file.".tmux.conf".source = /${config.home.homeDirectory}/Dotfiles/tmux/.tmux.conf; 
  home.file.".zshrc".source = /${config.home.homeDirectory}/Dotfiles/zsh/.zshrc; 
  home.file.".zsh_alias.conf".source = /${config.home.homeDirectory}/Dotfiles/zsh/.zsh_alias.conf; 
  home.file.".zsh_commands.conf".source = /${config.home.homeDirectory}/Dotfiles/zsh/.zsh_commands.conf; 
  home.file.".zsh_prompt.conf".source = /${config.home.homeDirectory}/Dotfiles/zsh/.zsh_prompt.conf; 

  programs.eza.enable = true;

  programs.lazygit.enable = true;
  ## Firefox cconfig
  programs.firefox.enable = true;
  programs.firefox.profiles.default.extensions.packages = with inputs.firefox-addons.packages.${pkgs.system}; [ darkreader bitwarden ublock-origin ];
 
  ## ObsidiaB config
  home.packages = [pkgs.obsidian];
  home.activation.makeTrampolineApps = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    builtins.readFile ./make-app-trampolines.sh
  );
}
