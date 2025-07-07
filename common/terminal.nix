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
  ];

  programs.zsh.enable = true;
  users.users.juan.shell = pkgs.zsh;

}
