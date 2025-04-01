{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    code-cursor
  ];  
}
