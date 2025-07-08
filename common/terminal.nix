{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kitty
    neovim
    zsh
    tmux
    eza
    stow
    unzip
    ripgrep
	gcc
	lazygit
  ];

  programs.zsh.enable = true;
  users.users.juan.shell = pkgs.zsh;

}
