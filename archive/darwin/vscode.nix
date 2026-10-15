{ vscodeExtensions, ... }:

{
		programs.vscode = {
				enable = true;
				extensions = with vscodeExtensions.extensions; [
						# bbenoist.nix
						# charliermarsh.ruff
						# ms-python.python
						];
				userSettings = {
				};
		};
}
