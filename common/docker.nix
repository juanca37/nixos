{ config, pkgs, ... }:

{
  virtualisation.docker.enable = true;
  # TEMPORARY (UPGRADE_LOG step 2): nixos-25.11 flags docker_28 as unmaintained.
  # Keep 28.x during the GNOME bisect; the 26.05 step moves to that branch's default.
  nixpkgs.config.permittedInsecurePackages = [ "docker-28.5.2" ];

  environment.systemPackages = with pkgs; [
    docker
  ];

}
