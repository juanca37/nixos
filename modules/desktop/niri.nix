
{ config, pkgs, ...}:
{

	programs.niri.enable = true;
	environment.sessionVariables = {
		# Fixes touch gestures
		MOZ_ENABLE_WAYLAND = "1";
		NIXOS_OZONE_WL = "1";
	};
}
