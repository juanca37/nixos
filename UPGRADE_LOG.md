# UPGRADE_LOG — zenbook-hexa

Rama: `upgrade/stepwise`. Un cambio de variable por paso. Nunca `switch`: `build` → diff → `sudo nixos-rebuild boot` → reinicio → resultado aquí.
No borrar generaciones ni hacer GC durante el proceso. Excepción acordada el 2026-11-14 tras el paso 2: limpieza única conservando las 3 últimas (45, 46, 47).

**Sesión nueva: leer este archivo primero y continuar por el primer paso sin resultado.**

## Generaciones de rescate (menú systemd-boot)

| Gen | nixpkgs | Kernel | Estado |
|---|---|---|---|
| 46 | `6e98748` (2025-07-16) | 6.15.6 | Paso 1 OK. GNOME 48. Rescate principal con la base vieja. |
| 47 | `b6018f8` (25.11) | 6.15.6 | Paso 2 OK. GNOME 49. |
| 48 | `b6018f8` (25.11) | 6.18.37 | Paso 3 OK. GNOME 49. |
| 45 | `6e98748` | 6.15.6 | Igual que 46 pero con niri. Nunca arrancada. |

Gens 1–44 (incluidas 40/41 y las fallidas 13/16/30/42/43) borradas a petición tras el paso 2. Su journal sigue disponible (`journalctl --list-boots`).

Menú de arranque: tras la limpieza seguían apareciendo 34 entradas antiguas `nixos-<hash64>.conf` (formato de nombre de otro builder de systemd-boot, probablemente el de las gens unstable/26.05); el builder de 25.11 solo poda `nixos-generation-N.conf`. Se borran a mano: `sudo find /boot/loader/entries -regextype posix-extended -regex '.*/nixos-[0-9a-f]{64}\.conf' -delete`. Revisar el menú otra vez tras el paso 4 (cambia el builder).

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
- Conclusión: el soporte llega con kernel 7.x → el paso 5 (`linuxPackages_latest` 7.3.4) es también el que debería arreglar el audio. Verificar entonces altavoces y micro.

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
