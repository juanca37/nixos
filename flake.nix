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
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    # Separate pin for fast-moving apps, exposed as `pkgs.latest.*` (overlays/default.nix).
    # Bumping it never drags the system (GNOME, Mesa, kernel) along:
    #   nix flake update nixpkgs-latest
    nixpkgs-latest.url = "github:nixos/nixpkgs/nixos-unstable";
    # Login screen (common/niri.nix). Only its NixOS module is used: nixpkgs 26.05 has none,
    # and unstable's sets an option 26.05 lacks. The package comes from pkgs.latest.
    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs-latest";
    };

    claude-code.url = "github:ryoppippi/nix-claude-code";
    # Claude Desktop: community repack of Anthropic's official Linux .deb.
    claude-desktop = {
      url = "github:poeck/claude-desktop-nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    omp.url = "github:can1357/oh-my-pi";
  };

  outputs = { self, home-manager, nixpkgs, claude-code, claude-desktop, omp, noctalia-greeter, ... }@inputs:
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
		modules = [
			./hosts/zenbook-hexa/default.nix
			home-manager.nixosModules.home-manager {
				home-manager.useGlobalPkgs = true;
				home-manager.useUserPackages = true;
			}
			noctalia-greeter.nixosModules.default
			./modules/users/juan/default.nix
			./modules/users/juan/desktop.nix
			./modules/users/juan/kubernetes.nix
      {
        nixpkgs.overlays = [
          claude-code.overlays.default
          claude-desktop.overlays.default
          self.overlays.modifications
          self.overlays.latest-packages
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
