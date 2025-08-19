{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # home-manager, used for managing user configuration

     darwin.url = "github:lnl7/nix-darwin";
     darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
firefox-addons = { url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons"; inputs.nixpkgs.follows = "nixpkgs"; };
nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = { self, nixpkgs, home-manager, darwin, nix-homebrew, ... } @inputs: let
    inherit (self) outputs;
    in {
    darwinConfigurations = {
      MBP-KFW2JYF66K = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./configuration.nix
		  nix-homebrew.darwinModules.nix-homebrew
		  {
				nix-homebrew = {
						enable = true;
						enableRosetta = true;
						autoMigrate = true;
						user = "Juan.Carrasco-1";
						};
				}
          # make home-manager as a module of nixos
          # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
	    home-manager.backupFileExtension = "backup";
            home-manager.users."Juan.Carrasco-1" = import ./home.nix;
	    home-manager.extraSpecialArgs= {inherit inputs outputs;};
            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
          }
        ];
      };
    };
  };
}
