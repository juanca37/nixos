{ lib, config, pkgs,  inputs, vscodeExtensions, ... }:
{
  home.stateVersion = "23.05"; # Please read the comment before changing.
  programs.home-manager.enable = true;
  imports = [
		./nvim.nix 
		./tmux.nix
		./zsh.nix
		./kitty.nix
		./firefox.nix
		(import ./vscode.nix {vscodeExtensions=vscodeExtensions;})
		];
  ## Obsidian config
  home.packages = [pkgs.obsidian pkgs.spotify pkgs.uv pkgs.gnupg pkgs.helmfile pkgs.bats pkgs.hoppscotch ];
  programs.zoxide = {
		enable = true;
		enableZshIntegration = true;
		options = [
				"cmd cd"
				];
		};
  programs.awscli.enable = true;
  programs.k9s = {
		enable = true;
		settings = {
				ui = {
						noIcons = false;
				};
				skin = "machiatto_transparent";
		};
		skins = {
				machiatto_transparent = ../assets/k9s/skins/machiatto-transparent.yaml;
				};
		views = {
			"v1/nodes" = {
			  columns = [
				"NAME"
				"STATUS"
				"ROLE"
				"AGE"
				"VERSION"
				"CAP_G:metadata.labels.eks.amazonaws.com/capacityType"
				"CAP_K:metadata.labels.karpenter.sh/capacity-type"
				"TYPE:metadata.labels.node.kubernetes.io/instance-type"
				"ZONE:metadata.labels.topology.kubernetes.io/zone"
			  ];
			};
			"v1/pods" = {
			  columns = [
				"NAME"
				"NAMESPACE"
				"STATUS"
				"READY"
				"RESTARTS"
				"CPU"
				"MEM"
				"CPU_LIMIT:spec.containers[*].resources.limits.cpu"
				"MEM_LIMIT:spec.containers[*].resources.limits.memory"
				"AGE"
			  ];
			};
		  };
		};
  # home.activation.makeTrampolineApps = lib.hm.dag.entryAfter [ "writeBoundary" ] (
  #   builtins.readFile ./make-app-trampolines.sh
  # );
}
