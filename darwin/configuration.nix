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
				autohide = true;
				persistent-apps = [
						"${pkgs.kitty}/Applications/kitty.app"
						"${pkgs.obsidian}/Applications/Obsidian.app"
						"/Applications/Microsoft Outlook.app"
						"/Applications/Slack.app"
						"${pkgs.firefox}/Applications/firefox.app"
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
				};
}
