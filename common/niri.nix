{ pkgs, ... }:
{
	# Adds "Niri" to GDM's session picker (gear icon after choosing the user).
	programs.niri.enable = true;

	# GDM normally preselects the last-used session; this resets it to GNOME on every GDM start,
	# so picking Niri once never makes it the default.
	services.displayManager.defaultSession = "gnome";

	environment.systemPackages = with pkgs; [
		xwayland-satellite # niri spawns it on demand for X11-only apps
	];
}
