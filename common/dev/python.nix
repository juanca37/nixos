{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    python313Packages.uv
    python313
  ];
}
