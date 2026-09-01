{ config, pkgs, ... }:

{
	imports = [
		./hardware.nix
		../../modules/hardware/boot-splash.nix
		../../modules/desktop/niri.nix
		../../common/docker.nix
	];

	## BOOT
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	## NETWORKING
	networking.hostName = "zenbook-hexa";
	networking.networkmanager.enable = true;


	## LOCALIZATION AND KEYBOARD
	time.timeZone = "Europe/Madrid";
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
	boot.initrd.kernelModules = [ "amdgpu" ];
	services.xserver.videoDrivers = ["amdgpu"];
	hardware.graphics = {
		enable = true;
	};

	## USER
	users.users.juan = {
		isNormalUser = true;
		description = "Juan";
		extraGroups = [
			"networkmanager"
			"wheel"
			"docker"
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
