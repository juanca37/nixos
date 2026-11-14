{
  description = ''
    For questions just DM me on X: https://twitter.com/@m3tam3re
    There is also some NIXOS content on my YT channel: https://www.youtube.com/@m3tam3re

    One of the best ways to learn NIXOS is to read other peoples configurations. I have personally learned a lot from Gabriel Fontes configs:
    https://github.com/Misterio77/nix-starter-configs
    https://github.com/Misterio77/nix-config

    Please also check out the starter configs mentioned above.
  '';

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    # TEMPORARY (UPGRADE_LOG step 2): keeps the kernel at 6.15.6 (same store path as
    # before the bump) so only userland changes in this step. Removed in step 3.
    nixpkgs-kernel.url = "github:nixos/nixpkgs/6e987485eb2c77e5dcc5af4e3c70843711ef9251";
    # Kept separate from the main `nixpkgs` pin so bumping fast-moving apps
    # (like zoom-us) never drags the whole system (GNOME, mesa, kernel) along.
    # Update just this input with: nix flake lock --update-input nixpkgs-latest
    nixpkgs-latest.url = "github:nixos/nixpkgs/nixos-unstable";

    claude-code.url = "github:ryoppippi/nix-claude-code";

    omp.url = "github:can1357/oh-my-pi";
  };

  outputs = { self, home-manager, nixpkgs, nixpkgs-latest, claude-code, omp, ... }@inputs:
    let
      inherit (self) outputs;
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      packages =
        forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      overlays = import ./overlays { inherit inputs; };
      nixosConfigurations = {
	zenbook-hexa = nixpkgs.lib.nixosSystem {
		system = "x86_64-linux";
		specialArgs = { inherit inputs; };
		modules = [
			./hosts/zenbook-hexa/default.nix
			home-manager.nixosModules.home-manager {
				home-manager.useGlobalPkgs = true;
				home-manager.useUserPackages = true;
			}
			./modules/users/juan/default.nix
			./modules/users/juan/desktop.nix
      {
        nixpkgs.overlays = [
          claude-code.overlays.default
          (final: prev: {
            zoom-us = (import nixpkgs-latest {
              system = final.stdenv.hostPlatform.system;
              config.allowUnfree = true;
            }).zoom-us;
          })
        ];
        home-manager.sharedModules = [
          omp.homeManagerModules.default
        ];
      }
			];
		};
      };
    };
}
