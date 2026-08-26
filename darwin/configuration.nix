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
  system.defaults = {
		dock = {
				autohide = false;
				show-recents = false;
				tilesize = 30;
				orientation = "left";
				show-process-indicators = false;
				persistent-apps = [
						"${pkgs.firefox}/Applications/firefox.app"
						"${pkgs.kitty}/Applications/kitty.app"
						"${pkgs.obsidian}/Applications/Obsidian.app"
						"/Applications/Microsoft Outlook.app"
						"/Applications/Slack.app"
						"/Applications/Microsoft Teams.app"
						];
		};
		NSGlobalDomain.AppleICUForce24HourTime = true;
		NSGlobalDomain.AppleInterfaceStyle = "Dark";
};
						
  system.primaryUser = "Juan.Carrasco-1";
  homebrew = {
		enable = true;
		casks = [
				"slack"
				];
		brews = [
				"nvm"
				];
		};
}
