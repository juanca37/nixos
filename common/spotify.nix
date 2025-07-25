{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ncspot
    playerctl
  ];

}
