{ inputs, ... }: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev:
    {
      claude-desktop = prev.claude-desktop.overrideAttrs (old: {
        postFixup = (old.postFixup or "") + ''
          wrapProgram $out/bin/claude-desktop \
            --prefix PATH : ${final.writeShellScriptBin "xdg-open" ''
              unset LD_LIBRARY_PATH
              exec /run/current-system/sw/bin/xdg-open "$@"
            ''}/bin
        '';
      });
    };

  # Fast-moving apps from the separate `nixpkgs-latest` input, as `pkgs.latest.<name>`.
  # Bump only these with: nix flake update nixpkgs-latest
  latest-packages = final: _prev: {
    latest = import inputs.nixpkgs-latest {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };
}
