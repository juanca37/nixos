{ pkgs, ... }:
{

  imports = [
	../common/browser.nix
	];
    environment.systemPackages = [ pkgs.vim
	pkgs.git ];
    nix.enable = false;
    system.stateVersion = 6;
    users.users."Juan.Carrasco-1" = {
        name = "Juan.Carrasco-1";
        home = "/Users/Juan.Carrasco-1";
    };
  nixpkgs.config.allowUnfree = true;
}
