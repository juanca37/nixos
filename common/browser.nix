{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    qutebrowser
  ];

}
