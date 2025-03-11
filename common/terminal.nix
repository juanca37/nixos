{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    neovim
    zsh
    tmux
    eza
    stow
  ];

  programs.zsh.enable = true;
  users.users.juan.shell = pkgs.zsh;

}
