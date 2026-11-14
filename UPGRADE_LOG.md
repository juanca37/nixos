# UPGRADE_LOG — zenbook-hexa

Rama: `upgrade/stepwise`. Un cambio de variable por paso. Nunca `switch`: `build` → diff → `sudo nixos-rebuild boot` → reinicio → resultado aquí.
No borrar generaciones ni hacer GC durante el proceso. Excepción acordada el 2026-11-14 tras el paso 2: limpieza única conservando las 3 últimas (45, 46, 47).
Desde el paso 7: GC automático semanal que conserva siempre las **10 últimas** generaciones del sistema (ver README).

**Sesión nueva: leer este archivo primero y continuar por el primer paso sin resultado.**

## Generaciones de rescate (menú systemd-boot)

| Gen | nixpkgs | Kernel | Estado |
|---|---|---|---|
| 46 | `6e98748` (2025-07-16) | 6.15.6 | Paso 1 OK. GNOME 48. Rescate principal con la base vieja. |
| 47 | `b6018f8` (25.11) | 6.15.6 | Paso 2 OK. GNOME 49. |
| 48 | `b6018f8` (25.11) | 6.18.37 | Paso 3 OK. GNOME 49. |
| 49 | `f1e5c35` (26.05) | 6.18.63 | Paso 4 OK. GNOME 50.6. **Rescate principal moderno** (sin audio interno). |
| 51 | `f1e5c35` (26.05) | 6.18.63 / 7.3.4 | Por defecto = 6.18.63. Entrada `k7-noreplay` (7.3.4 + `dcdebugmask=0x400`) probada OK. No usar `k7-noreplay-nopsr` (sin probar). |
| 52 | `f1e5c35` (26.05) | 7.3.4 | Paso 5c OK. Kernel 7.3.4 + Panel Replay off, initrd scripted. **Rescate principal con audio interno.** |
| 53 | `f1e5c35` (26.05) | 7.3.4 | Paso 6 OK. systemd-initrd. |
| 50 | `f1e5c35` (26.05) | 7.3.4 | **KO**: greeter congelado. No arrancar. |
| 45 | `6e98748` | 6.15.6 | Igual que 46 pero con niri. Nunca arrancada. |

Gens 1–44 (incluidas 40/41 y las fallidas 13/16/30/42/43) borradas a petición tras el paso 2. Su journal sigue disponible (`journalctl --list-boots`).

Menú de arranque: tras la limpieza seguían apareciendo 34 entradas antiguas `nixos-<hash64>.conf` (formato de nombre de otro builder de systemd-boot, probablemente el de las gens unstable/26.05); el builder de 25.11 solo poda `nixos-generation-N.conf`. Borradas a mano con `sudo find /boot/loader/entries -regextype posix-extended -regex '.*/nixos-[0-9a-f]{64}\.conf' -delete`. Tras el paso 4 el menú solo tiene 45–49 + firmware setup: OK.

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

## Audio interno (altavoces + micro)

- **Nunca ha funcionado** en kernels 6.x (confirmado por el usuario). Bluetooth sí.
- Hardware: ACP 7.0 + SoundWire + 4 amplificadores Cirrus cs35l56 + DMIC.
- Kernel 6.15.6 y 6.18.x (incluida gen 1 y gen 48): `acp_asoc_acp70.0: No matching ASoC machine driver found` → solo existe la tarjeta HDMI (`HD-Audio Generic`).
- Kernel 7.2.x (gens fallidas): se registra la tarjeta `amd-soundwire` (card1), firmware DSP de los cs35l56 cargado y "Calibration applied" ×4.
- Kernel 7.3.4 (gen 50, boot del 2026-11-14 19:23): `cs42l43 sdw:0:1:01fa:4243:01: Initialization not complete` y `platform amd_sdw: deferred probe pending` en el minuto que duró el arranque (pantalla congelada).
- Kernel 7.3.4 + `amdgpu.dcdebugmask=0x400` (gen 51 `k7-noreplay`): tarjeta `amd-soundwire` (card1, `ZenbookS16UM5606GA`), cs42l43 inicializa, cs35l56 "Calibration applied" ×4. PipeWire: sinks Speaker + Headphones, source Microphones. **Altavoces funcionan** (confirmado por el usuario).
- Conclusión: el audio interno necesita kernel 7.x; con Panel Replay desactivado, 7.x es usable.

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
| 1 | `4cba327` | 46 | **OK** (2026-11-14) | nixpkgs `6e98748`, HM `d0300c8`, kernel 6.15.6, GNOME 48.3, Mesa 25.1.6. Diff vs gen 45: solo sale niri 25.05.1, seatd, swaylock.pam, config.kdl. Login, apps, suspensión: bien. Nueva generación de rescate. |
| 2 | `1288042` | 47 | **OK** (2026-11-14) | nixpkgs `b6018f8` (25.11, 2026-06-30, rama ya sin soporte), HM `3ee51fb` (release-25.11, follows). Kernel **mismo binario** 6.15.6 vía input temporal `nixpkgs-kernel`; initrd scripted. GNOME 48.3→49.4, mutter 49.4, GDM 49.2, gnome-session 49.2, Mesa 25.1.6→25.2.6, linux-firmware 20260622, systemd 258.7, docker 28.5.2 (permitido temporalmente como inseguro). Renames git `settings.user.*` y `stdenv.hostPlatform.system`. Closure `ba7b1vfa…`. Cuadrícula de apps, apps, suspensión y docker: bien. → GNOME 49 + Mesa 25.2 no son el problema. |
| 3 | `c2e44f4` | 48 | **OK** (2026-11-14) | Solo kernel: 6.15.6 → 6.18.37 (`linuxPackages_6_18` de 25.11). Eliminado el input temporal `nixpkgs-kernel`. Diff: solo kernel, módulos e initrd regenerado; initrd sigue scripted, Plymouth igual. nixpkgs/HM/GNOME/Mesa sin cambios. Closure `lhjg21x4…`. Todo bien. Audio interno sigue sin funcionar (igual que siempre en 6.x, ver sección Audio). |
| 4 | `1e9b071` | 49 | **OK** (2026-11-14) | nixpkgs `f1e5c35` (26.05, 2026-11-13), HM `6eb2d33` (release-26.05, follows). Kernel 6.18.37 → 6.18.63 (misma serie). **initrd scripted fijado** (`boot.initrd.systemd.enable = false`, temporal: 26.05 usa systemd-initrd por defecto, y el scripted desaparece en 26.11). GNOME 49.4→50.6, mutter 50.6, GDM 50.3, gnome-session 50.1, gnome-keyring 50.0, Mesa 25.2.6→26.1.8, linux-firmware 20261019, systemd 260.5, pipewire 1.6.6, Plymouth 26.134, docker 28.5.2→29.9.3 (por defecto de 26.05; quitada la excepción de inseguro). Closure `4pqj8xmn…`. Cuadrícula con apps, apps lanzan (kitty, Zoom), GNOME 50 ofrece más niveles de escalado. → **GNOME 50 + Mesa 26.1 no son el problema.** Sospechosos restantes: kernel 7.x, systemd-initrd, Mesa 26.2+. |
| 5 | `6d529d6` | 50 | **KO** (2026-11-14) | Solo kernel: 6.18.63 → **7.3.4**. Síntoma: greeter de GDM congelado; no se puede entrar o no se ve. Journal (boot 236fcd16): gnome-shell 50.6 arranca y se registra en GDM a los 10 s, sin errores de amdgpu, KMS ni gnome-shell; luego botón de encendido → suspensión. Misma firmware DMUB 0x09005700 que en 6.18.63 (gen 49, OK) y mismo userland → **el culpable es el driver de pantalla de amdgpu en 7.x** (Display Core 3.2.351 → 3.2.392). Indicio: en 6.18 el kernel registra `eDP-1: PSR support 1`; en 7.2/7.3 esa línea desaparece, lo que encaja con que el eDP pase a Panel Replay [INFERENCIA]. Confirma también el KO de octubre (7.2.x). **Ojo:** la gen 50 queda como entrada por defecto del menú hasta instalar el paso 5b. |
| 5b | `bd7588b` | 51 | **OK** (2026-11-14) en `k7-noreplay` | Entrada por defecto = kernel 6.18.63. Specialisations: `k7-noreplay` (`amdgpu.dcdebugmask=0x400`) y `k7-noreplay-nopsr` (`0x410`). **`k7-noreplay` OK**: kernel 7.3.4, greeter y sesión bien, apps lanzan, sin errores de amdgpu; ahora el kernel registra `eDP-1: PSR support 0`. Altavoces funcionan. → **Causa del congelado de GDM: eDP Panel Replay en el driver amdgpu de kernel 7.x.** `k7-noreplay-nopsr` no hizo falta. |
| 5c | `070b2cc` | 52 | **OK** (2026-11-14) | Promovido `k7-noreplay` a la entrada por defecto: `linuxPackages_latest` + `amdgpu.dcdebugmask=0x400`; specialisations eliminadas. Kernel, initrd y kernel-params idénticos al boot `k7-noreplay`; `diff-closures` vacío. Closure `qhfa34bw…`. Arranca sin elegir nada en el menú; `uname -r` = 7.3.4. Suspensión/reanudación OK en el boot `k7-noreplay` (1 ciclo). |
| 6 | `8f763ac` | 53 | **OK** (2026-11-14) | Solo initrd: scripted → **systemd-initrd** (por defecto en 26.05; el scripted se elimina en 26.11). Diff: solo `initrd-linux` y `root=fstab` en kernel-params. Plymouth, greeter, login, audio interno (4× "Calibration applied"): bien. → Plymouth en initrd no influía en el KO de octubre. |
| 7 | (este commit) | 54 (prevista) | pendiente | Limpieza final, sin cambios de kernel/initrd/GNOME/Mesa (kernel e initrd idénticos a gen 53; systemd del sistema 260.5 igual). Overlay `pkgs.latest` (input `nixpkgs-latest`, actualizado a `d4f25a3` 2026-11-11) para slack 4.51, vscode 1.144, zoom 7.2.5, postman 12.20, bruno 4.3, drawio 32.6, dbeaver 26.2.4; eliminado el overlay suelto de zoom. Quitado el input `nixpkgs-stable` (23.11, sin uso). Integrado `hosts/common` (borrado): `nix.optimise`, GC semanal que poda a las 10 últimas generaciones (`nix-env --delete-generations +10`, probado en un perfil de prueba) y `configurationLimit = 10`. Un solo agente SSH: gcr (tiene las 2 claves); `services.gpg-agent.enableSshSupport` quitado (gpg-agent no tenía identidades). README con las dos vías de actualización. Closure `hj4771y2…`. Se puede aplicar con `switch` (sin cambio de kernel). |

## Resumen

- **Causa del congelado de GDM:** eDP Panel Replay en el driver de pantalla de amdgpu de kernel 7.x (7.2 y 7.3) en este panel. Arreglo: `amdgpu.dcdebugmask=0x400`. GNOME 49/50, Mesa 25.2/26.1, systemd-initrd, Plymouth, los dos agentes SSH y home-manager no tenían nada que ver.
- **niri:** se quedaba muerto por la misma causa (kernel 7.2); eliminado por decisión del usuario.
- **Audio interno:** requiere kernel 7.x; funciona desde el paso 5b.
- **Estado final:** NixOS 26.05, GNOME 50.6, Mesa 26.1.8, kernel 7.3.4 (`linuxPackages_latest`) + Panel Replay off, systemd-initrd, home-manager release-26.05.
