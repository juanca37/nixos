# UPGRADE_LOG — zenbook-hexa

Rama: `upgrade/stepwise`. Un cambio de variable por paso. Nunca `switch`: `build` → diff → `sudo nixos-rebuild boot` → reinicio → resultado aquí.
Prohibido borrar generaciones o hacer GC durante el proceso.

**Sesión nueva: leer este archivo primero y continuar por el primer paso sin resultado.**

## Generaciones de rescate (menú systemd-boot)

| Gen | nixpkgs | Kernel | Estado |
|---|---|---|---|
| 40 | `6e98748` (2025-07-16) | 6.15.6 | Arrancada a diario (boot 0 desde 2026-10-29). Buena. |
| 41 | `6e98748` | 6.15.6 | Buena (boots -7, -5). |
| 45 | `6e98748` | 6.15.6 | = HEAD de `main` (incluye `bec599c` zona horaria). Aplicada en caliente; pendiente de arrancar (paso 1). |

## Paso 0 — Diagnóstico (2026-11-14)

- Arrancado: gen 40. `/run/current-system`: gen 45. Lock de `main` ya revertido en `31019ec`: nixpkgs del sistema = nodo `nixpkgs_2` = `6e98748`; el nodo `nixpkgs` (`e5bdc4a`) es de claude-code. home-manager `d0300c8` (master, 2025-07-18).
- Fallidas: gens 13, 16 (unstable 2026-08-31, kernel 7.2.2), 30 (2026-09-13, 7.2.5), 42, 43 (2026-10-03, 7.2.9). Todas GNOME/mutter 50.4, Mesa 26.2, initrd con systemd + Plymouth en initrd.
- GDM **no** es el problema: en 7 de 9 arranques fallidos el login funcionó.
- GNOME 50 (gen 43): shell vivo, la búsqueda recibe teclado (lanza search providers), pero **cuadrícula de Actividades vacía**; 0 apps lanzadas. Las apps sí estaban en el closure (101 sistema + 14 usuario). Fallo de descubrimiento de apps en la sesión, no de pantalla.
- niri (gens 13/16/42): arranca y carga config, pero queda **muerto**; `libinput ... lagging behind by 755ms` (compositor bloqueado). Sospecha: gráficos (kernel 7.2 / Mesa 26.2).
- Gen 1 (instalación NixOS 26.05, GNOME 50.4, kernel 6.18.46, sin Plymouth, sin config propia) funcionó 4 arranques / 2,5 h.
- Descartado como causa: dos agentes SSH (gcr + gpg-agent activos también en boots buenos). Se limpiará igualmente.
- home-manager en master: real, pero solo afecta a la sesión/evaluación. Se fija a rama release al subir nixpkgs.
- Pulsar el botón de encendido = suspender (gsd-media-keys). No usarlo durante las pruebas.

## Versiones disponibles (evaluado 2026-11-14)

| nixpkgs | GNOME | Mesa | LTS | 6.18 | latest | linux-firmware | niri |
|---|---|---|---|---|---|---|---|
| `6e98748` (actual) | 48.3 | 25.1.6 | 6.12.38 | — | 6.15.6 | 20250708 | 25.05.1 |
| nixos-25.11 `b6018f8` | 49.4 | 25.2.6 | 6.12.93 | 6.18.37 | 7.1.2 | 20260622 | 25.11 |
| nixos-26.05 `f1e5c35` | 50.6 | 26.1.8 | 6.18.63 | 6.18.63 | 7.3.4 | 20261019 | 26.04 |
| nixos-unstable `d4f25a3` | 51.0 | 26.3.0 | 6.18.63 | 6.18.63 | 7.3.4 | 20261019 | 26.04 |

home-manager: release-25.11 `3ee51fb`, release-26.05 `6eb2d33`, master `82ce401`.

## Plan

| Paso | Cambio (única variable) | nixpkgs | HM | Kernel | GNOME | Mesa | initrd |
|---|---|---|---|---|---|---|---|
| 1 | Línea base + **quitar niri** (solo GNOME; vars Wayland movidas al host) | `6e98748` | `d0300c8` | 6.15.6 | 48.3 | 25.1.6 | scripted |
| 2 | nixpkgs → 25.11 + HM release-25.11 (follows). Kernel fijado al de `6e98748` | 25.11 | r-25.11 | 6.15.6 | 49.4 | 25.2.6 | scripted (fijado) |
| 3 | Kernel → `linuxPackages_6_18` | 25.11 | r-25.11 | 6.18.37 | 49.4 | 25.2.6 | scripted |
| 4 | nixpkgs → 26.05 + HM release-26.05 (kernel 6.18, solo sube el parche) | 26.05 | r-26.05 | 6.18.63 | 50.6 | 26.1.8 | scripted |
| 5 | Kernel → `linuxPackages_latest` | 26.05 | r-26.05 | 7.3.4 | 50.6 | 26.1.8 | scripted |
| 6 | (Opcional) nixos-unstable | unstable | master | — | 51.0 | 26.3.0 | — |

Si un paso sale KO: revisar `journalctl -b -1`, proponer UN cambio aislado (orden: agente SSH único → sin Plymouth → sin `amdgpu` en initrd) y explicar la hipótesis antes.

Decisión 2026-11-14: solo GNOME, niri eliminado (no se prueba).

## Protocolo de prueba (cada reinicio)

1. Arrancar la entrada por defecto. Anotar si se ve Plymouth y el greeter.
2. GDM → engranaje → **GNOME** → entrar.
3. Super: ¿cuadrícula con apps? Abrir Consola y Firefox.
4. Suspender desde el menú del sistema (no con el botón) y reanudar.
5. Si algo falla: `Ctrl+Alt+F3`, entrar y ejecutar:
   ```sh
   journalctl -b -o short-monotonic > ~/ko-journal.log
   systemctl --user show-environment > ~/ko-env.txt
   gsettings get org.gnome.shell app-picker-layout > ~/ko-layout.txt
   sudo systemctl reboot   # y elegir la gen 45 (o 40) en el menú
   ```

## Resultados

| Paso | Commit | Gen | Resultado | Síntomas / notas |
|---|---|---|---|---|
| 0 | — | — | Diagnóstico hecho | Ver arriba |
| 1 | (este commit) | 46 (prevista) | pendiente | Diff vs gen 45: solo sale niri 25.05.1, seatd, swaylock.pam, config.kdl. Kernel/GNOME/Mesa sin cambios. |
