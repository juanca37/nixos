# nixcfg — zenbook-hexa

NixOS flake for an ASUS Zenbook S16 (UM5606GA, AMD Strix). Host: `zenbook-hexa`. Desktop: niri + Noctalia (default session), with GNOME still available; login via Noctalia Greeter on greetd (Wayland).

## Layout

| Path | What |
|---|---|
| `flake.nix` | Inputs and the `zenbook-hexa` system |
| `hosts/zenbook-hexa/` | Host config: boot, kernel, GNOME, Nix GC, hardware |
| `modules/users/juan/` | User + home-manager (CLI tools, apps, git, gpg) |
| `modules/hardware/boot-splash.nix` | Plymouth + quiet boot |
| `common/niri.nix` | niri session, Noctalia shell, Noctalia Greeter login screen (niri preselected) |
| `overlays/default.nix` | `pkgs.latest.*` overlay (fast-moving apps) |
| `UPGRADE_LOG.md` | History of the 2026-11 stepwise upgrade and why the kernel needs a quirk |

## Two independent update tracks

| Track | Flake input | Follows | What it moves |
|---|---|---|---|
| System | `nixpkgs` (`nixos-26.05`) + `home-manager` (`release-26.05`) | Stable release branch | Kernel, GNOME, Mesa, systemd, CLI tools |
| Apps | `nixpkgs-latest` (`nixos-unstable`) | Unstable | Only what is listed under `pkgs.latest` (Slack, VS Code, Zoom, Postman, Bruno, draw.io, DBeaver) |

`home-manager` follows `nixpkgs`, so they always move together.

### Update apps only (safe, frequent)

```sh
nix flake update nixpkgs-latest
nixos-rebuild build --flake .#zenbook-hexa
nix store diff-closures /run/current-system ./result   # only the apps should change
sudo nixos-rebuild switch --flake .#zenbook-hexa
```

No reboot needed. To move another app to this track, list it under `with pkgs.latest; [ ... ]` in `modules/users/juan/desktop.nix` (or set `package = pkgs.latest.<name>;` for `programs.*` options, like VS Code).

Claude Code, Claude Desktop and omp come from their own flake inputs, not `pkgs.latest`. Update them the same way, by input name:

```sh
nix flake update claude-code claude-desktop omp
```

`nix flake update` with no arguments updates **everything**, system included. Always name the inputs.

### Update the system (patch updates within the release)

```sh
nix flake update nixpkgs home-manager
nixos-rebuild build --flake .#zenbook-hexa
nix store diff-closures /run/current-system ./result
sudo nixos-rebuild boot --flake .#zenbook-hexa
# reboot; if anything breaks, pick the previous generation in the boot menu
```

Use `boot`, not `switch`, whenever the kernel, Mesa, GNOME or systemd change.

### Move to the next NixOS release (e.g. 26.11)

Change both branch names in `flake.nix` together (`nixos-26.05` → `nixos-26.11`, `release-26.05` → `release-26.11`), run `nix flake update nixpkgs home-manager`, fix any renamed-option warnings from the build, then `boot` and reboot. Do one thing per reboot; see `UPGRADE_LOG.md` for the procedure.

## Hardware quirk: kernel and display

- Kernel: `linuxPackages_latest` (7.x). Needed for the internal speakers and mic (ACP 7.0 SoundWire). On 6.x only HDMI/Bluetooth audio exists.
- `amdgpu.dcdebugmask=0x400` (disable eDP Panel Replay) is **required** on kernel 7.x: without it the screen froze at the login screen (then GDM). Keep it until a newer kernel is confirmed to work without it (test that as its own reboot).
- Fallback if a kernel update breaks the display: `boot.kernelPackages = pkgs.linuxPackages_6_18;` (no internal audio).

## Garbage collection

Automatic and weekly (`hosts/zenbook-hexa/default.nix`): keeps the **last 10 system generations** regardless of age, then removes unreferenced store paths. The boot menu also shows at most 10 entries. Nix store is deduplicated weekly (`nix.optimise`).

Never run `nix-collect-garbage -d` or `--delete-older-than` by hand: they can leave only the current generation and no rescue entries.

## Notes

- SSH keys are served by GNOME's agent (`SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gcr/ssh`); gpg-agent only handles GPG.
- Dotfiles (zsh, tmux, niri, noctalia) are symlinked out of the store from `~/Projects/Dotfiles`.
- `home/` and `archive/` are not used by the flake.

## niri (default session)

The login screen is Noctalia Greeter on greetd (`common/niri.nix`; module from the `noctalia-greeter` flake input, package `pkgs.latest.noctalia-greeter`). It always preselects juan and **Niri**; GNOME is in its session picker.

- Login and lock screen match: Noctalia copies its wallpaper, colours, font and monitor scale to the greeter whenever they change (`[shell.greeter_sync] auto_sync` in `Dotfiles/noctalia/config.toml`), without a password (polkit rule from `passwordless-sync-users`). Force one with `noctalia msg greeter-sync` or Settings → Security → Noctalia Greeter → Sync Now; it shows on the next login screen.
- greetd's PAM unlocks the GNOME keyring at login (SSH keys).
- Greeter state: `/var/lib/noctalia-greeter/` (`greeter.toml` from Nix, `sync.toml` + wallpaper from Sync).
- GNOME's own lock screen needs GDM, so locking inside a GNOME session doesn't work with this login screen.
- Changing the display manager only takes effect after a reboot (`nixos-rebuild boot`, then reboot); greetd is never restarted by `switch`.

- `Mod` = Super (Windows key). `Mod+Shift+'` (i.e. `Mod+?`) lists the important hotkeys.
- `Mod+Space` launcher, `Mod+T` kitty, `Mod+S` control center, `Mod+Shift+,` Noctalia settings, `Super+Alt+L` lock, `Mod+O` overview, `Mod+Shift+E` quit.
- The bar, launcher, notifications, lock screen and wallpaper are all Noctalia (`pkgs.latest.noctalia`), started by niri's `spawn-at-startup`.
- Noctalia is patched (`overlays/noctalia-remove-history-on-open.patch`): clicking a notification or one of its actions, from the toast or the bell's list, also removes it from history. That patch can stop applying after `nix flake update nixpkgs-latest`.
- Configs: `Dotfiles/niri/config.kdl`, `Dotfiles/noctalia/config.toml`. Settings changed in the Noctalia GUI are saved to `~/.local/state/noctalia/settings.toml` (not in Dotfiles) and override the TOML.
- niri reloads `config.kdl` on save; check it with `niri validate`. Noctalia: `noctalia config validate`.
- Zoom runs as a native Wayland app (`xwayland=false` in `~/.config/zoomus.conf`, not managed here). Through XWayland its screen-share annotation layer showed up as a black screen. In niri, window rules in `config.kdl` float the annotation layer (app-id `Zoom`, title `zoom`) and the sharing bar (`as_toolbar`). `niri-zoom-share-follow` (`common/niri.nix`, started by `spawn-at-startup`) keeps both on the focused workspace, snaps the annotation layer to the full output, and hands focus back to the sharing bar whenever the layer takes it, so the bar stays on top and Stop share stays clickable (the text annotation tool therefore doesn't get keyboard input). Zoom only allows annotation on Wayland sessions when you share the entire screen on a single monitor, and at output scale 1.5 it limits annotation to the top-left 2/3 of the screen; it is only correct at scale 1. `Mod+Z` (`niri-zoom-present-scale`) toggles between scale 1 and the automatic 1.5: press it before sharing and again after.
