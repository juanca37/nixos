{ config, pkgs, ... }:
let
	# Zoom (native Wayland, app-id "Zoom") opens its screen-share annotation layer ("zoom") and
	# sharing bar ("as_toolbar") as windows on one workspace; niri has no "show on all workspaces".
	# This keeps them on whichever workspace is focused, so you can annotate what you present.
	# It also snaps the annotation layer to exactly the full output: niri places floating windows
	# inside the working area (below Noctalia's bar), while the layer has to cover the whole
	# captured screen.
	# Started by spawn-at-startup in Dotfiles/niri/config.kdl. Assumes a single monitor:
	# workspaces are addressed by index on the focused output.
	niri-zoom-share-follow = pkgs.writeShellApplication {
		name = "niri-zoom-share-follow";
		runtimeInputs = [ config.programs.niri.package pkgs.jq ];
		text = ''
			share_windows='.[] | select(.app_id == "Zoom" and (.title == "zoom" or .title == "as_toolbar"))'

			# move-floating-window treats "+N"/"-N" as relative moves; this undoes an offset of $1.
			undo_offset() { if [ "$1" -ge 0 ]; then echo "-$1"; else echo "+$(( -$1 ))"; fi; }

			fit_overlay() {
				local out_w out_h id x y w h
				read -r out_w out_h < <(niri msg --json focused-output | jq -r '.logical | "\(.width) \(.height)"')
				[ -n "$out_h" ] || return 0
				niri msg --json windows \
					| jq -r '.[] | select(.app_id == "Zoom" and .title == "zoom" and .is_floating and .layout.tile_pos_in_workspace_view != null)
						| [.id, (.layout.tile_pos_in_workspace_view[] | round), .layout.window_size[]] | @tsv' \
					| while read -r id x y w h; do
						if [ "$x" -ne 0 ] || [ "$y" -ne 0 ]; then
							niri msg action move-floating-window --id "$id" -x "$(undo_offset "$x")" -y "$(undo_offset "$y")"
						fi
						[ "$w" -eq "$out_w" ] || niri msg action set-window-width --id "$id" "$out_w"
						[ "$h" -eq "$out_h" ] || niri msg action set-window-height --id "$id" "$out_h"
					done
			}

			# niri raises the focused floating window. Clicking the full-screen annotation layer
			# (to draw) would bury the sharing bar under it and make "Stop share" unclickable, so
			# hand focus back to the bar; drawing only needs the pointer, not keyboard focus.
			# A window that opens focused only reports it via is_focused, not WindowFocusChanged,
			# so this also runs from sync.
			keep_bar_on_top() {
				niri msg --json windows \
					| jq -r '
						if any(.[]; .is_focused and .app_id == "Zoom" and .title == "zoom")
						then .[] | select(.app_id == "Zoom" and .title == "as_toolbar") | .id
						else empty end' \
					| while read -r bar; do
						niri msg action focus-window --id "$bar"
					done
			}

			sync() {
				local ws_id ws_idx
				read -r ws_id ws_idx < <(niri msg --json workspaces | jq -r '.[] | select(.is_focused) | "\(.id) \(.idx)"')
				[ -n "$ws_idx" ] || return 0
				niri msg --json windows \
					| jq -r --argjson ws "$ws_id" "$share_windows | select(.workspace_id != \$ws) | .id" \
					| while read -r win; do
						niri msg action move-window-to-workspace --window-id "$win" --focus false "$ws_idx"
					done
				fit_overlay
				keep_bar_on_top
			}

			niri msg --json event-stream \
				| jq --unbuffered -r '
					if .WorkspaceActivated.focused == true then "sync"
					elif (.WindowOpenedOrChanged.window // {} | .app_id == "Zoom" and (.title == "zoom" or .title == "as_toolbar")) then "sync"
					elif .WindowFocusChanged then "focus"
					else empty end' \
				| while read -r event; do
					case "$event" in
						sync) sync ;;
						focus) keep_bar_on_top ;;
					esac
				done
		'';
	};

	# Zoom only lines up screen-share annotations with the cursor at output scale 1 (at 1.5 it
	# limits drawing to the top-left 2/3 of the screen). Toggles the focused output between scale 1
	# for sharing and niri's automatic scale (1.5 on this panel). Bound to Mod+Z in config.kdl.
	niri-zoom-present-scale = pkgs.writeShellApplication {
		name = "niri-zoom-present-scale";
		runtimeInputs = [ config.programs.niri.package pkgs.jq ];
		text = ''
			read -r name at_one < <(niri msg --json focused-output | jq -r '"\(.name) \(.logical.scale == 1)"')
			if [ "$at_one" = true ]; then
				niri msg output "$name" scale auto
			else
				niri msg output "$name" scale 1
			fi
		'';
	};
in
{
	# Adds "Niri" to GDM's session picker (gear icon after choosing the user).
	programs.niri.enable = true;

	# GDM normally preselects the last-used session; this resets it to GNOME on every GDM start,
	# so picking Niri once never makes it the default.
	services.displayManager.defaultSession = "gnome";

	environment.systemPackages = with pkgs; [
		xwayland-satellite # niri spawns it on demand for X11-only apps
		latest.noctalia # desktop shell (bar, launcher, notifications, lock); started by niri's config
		niri-zoom-share-follow
		niri-zoom-present-scale
	];
}
