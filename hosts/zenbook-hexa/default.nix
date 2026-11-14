{ config, pkgs, ... }:

{
	imports = [
		./hardware.nix
		../../modules/hardware/boot-splash.nix
		../../modules/desktop/niri.nix
		../../common/docker.nix
	];

	programs.nix-ld.enable = true;

	## BOOT
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	## NETWORKING
	networking.hostName = "zenbook-hexa";
	networking.networkmanager.enable = true;


	## LOCALIZATION AND KEYBOARD
	time.timeZone = null; # Managed at runtime by automatic-timezoned / timedatectl / UI
	services.automatic-timezoned.enable = true;
	# GNOME disables the geoclue demo agent, which drops it from the whitelist, but
	# automatic-timezoned runs that agent. Unlisted, geoclue never answers and the service dies.
	services.geoclue2.whitelistedAgents = [
		"gnome-shell"
		"io.elementary.desktop.agent-geoclue2"
		"geoclue-demo-agent"
	];
	i18n.defaultLocale = "es_ES.UTF-8";
	i18n.extraLocaleSettings.LC_MESSAGES = "en_US.UTF-8"; # Keeps system errors in English
	services.xserver.xkb = {
		layout = "es";
		variant = "";
	};
	console = {
		keyMap = "es";
	};
	## GRAPHICAL 
	services.xserver.enable = true;
	services.displayManager.gdm.enable = true;
	services.xserver.desktopManager.gnome.enable = true;
	services.flatpak.enable = true;
	boot.initrd.kernelModules = [ "amdgpu" ];
	services.xserver.videoDrivers = ["amdgpu"];
	hardware.graphics = {
		enable = true;
	};

	## PRINTING
	services.printing = {
		enable = true;
		drivers = [ pkgs.gutenprint pkgs.epson-escpr ];
	};
	services.avahi = {
		enable = true;
		nssmdns4 = true;
		openFirewall = true;
	};

	## USER
	programs.zsh.enable = true;
	users.users.juan = {
		isNormalUser = true;
		description = "Juan";
		shell = pkgs.zsh;
		extraGroups = [
			"networkmanager"
			"wheel"
			"docker"
			"lpadmin"
		];
	};

	# SYSTEM PACKAGES
	environment.systemPackages = with pkgs; [
		git
		wget
		curl
		vim
	];

	## NIX CONFIGURATION
	nix.settings.experimental-features = [ "nix-command" "flakes" ];

	## SYSTEM CONFIGURATION
	boot.kernelPackages = pkgs.linuxPackages_latest;
	system.stateVersion = "24.11";
}
