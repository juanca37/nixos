{ config, pkgs, ... }:
{
  # Minimum required for Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;  # Needed for X11 apps
  };

  # Absolute minimum packages
  environment.systemPackages = with pkgs; [
    hyprland
    xdg-desktop-portal-hyprland
    kitty  # or your preferred terminal
    wofi
    waybar
    pavucontrol # Audio control
    networkmanagerapplet # Network tray
    hyprshot
    hyprlock
    hyprpaper
  ];

  # Required core services
  services.dbus.enable = true;
  xdg.portal.enable = true;
  security.polkit.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.sddm = {
    enable = true;
    theme = "maldives";
  };

  services.blueman.enable = true;
}