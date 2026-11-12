# Verified upstream implementation inputs (2026-11-12)

## Dux suite
Use release-tag flakes and leave their nixpkgs inputs independent of system stable: shell has Go 1.27.3 in core/go.mod and flake computes pkgs.go_1_27; other suite packages compute Go version too. NixOS modules build their defaults against system pkgs regardless of flake follows, so explicitly set module package to input packages.${pkgs.stdenv.hostPlatform.system}.default to retain upstream build package set. Shell also needs recent Quickshell (option says >=0.3.0).

| Input URL | package output | NixOS module | option |
|---|---|---|---|
| github:duxlabs-dev/dux-shell/v2.1.2 | dms-shell/default | nixosModules.default | programs.dank-material-shell.enable |
| github:duxlabs-dev/dux-files/v2.1.2 | dux-files/default | nixosModules.default | programs.dux-files.enable |
| github:duxlabs-dev/dux-greeter/v2.1.2 | dms-greeter/default | nixosModules.default | programs.dms-greeter.enable |
| github:duxlabs-dev/dux-search/v2.1.1 | dsearch/default | none (homeModules.default only) | use user service below |

DMS options systemd.enable default false; systemd.target default graphical-session.target. Other features true by default: enableSystemMonitoring, enableVPN, enableDynamicTheming, enableAudioWavelength, enableCalendarEvents. Old enableBrightnessControl/enableColorPicker/enableClipboard removed because built in. Config paths current .config/dms/settings.json and .local/state/dms/session.json.

Dux files options systemd.enable false, systemd.target graphical-session.target; portal.enable false, portal.preferred false, portal.desktop common. Module registers D-Bus package, polkit paths, and portal if enabled. Desktop ID dev.duxlabs.files.desktop; executable dfiles.

Greeter requires compositor.name (this repository uses "hyprland"); compositor.package optional override otherwise reads programs.niri.package; The optional configHome copies settings/state/cache including wallpaper; this repository deliberately leaves it unset. Module enables greetd via mkDefault. Supports NixOS displayManager autoLogin if configured; fonts material-symbols/inter/fira-code installed. Greeter package override necessary as above. No separate quickshell needed for files/greeter current embedded runtime.

Dsearch Home Manager module uses user service Type=simple, ExecStart=${package}/bin/dsearch serve, Restart=on-failure, RestartSec=5s, TimeoutStopSec=30s, WantedBy=default.target. Adapt to NixOS systemd.user.services for Hjem setup. Config optional TOML at .config/dsearch/config.toml.

All Dux packages MIT, x86_64-linux/aarch64-linux. Sources: [shell flake](https://github.com/duxlabs-dev/dux-shell/blob/v2.1.2/flake.nix), [shell module/options](https://github.com/duxlabs-dev/dux-shell/tree/v2.1.2/distro/nix), [files flake/module](https://github.com/duxlabs-dev/dux-files/tree/v2.1.2/distro/nix), [greeter module](https://github.com/duxlabs-dev/dux-greeter/blob/v2.1.2/distro/nix/greeter.nix), [search module](https://github.com/duxlabs-dev/dux-search/blob/v2.1.1/distro/nix/default.nix).

## Hex
`github:anomalyco/hex/v3.4.0` stable tag; default branch is dev, avoid untagged input. Exports packages.hex/default; nixosModules.hex/default; enable programs.hex.enable. Module installs desktop package only (no daemon), derives default package from flake packages (upstream nixpkgs). Linux x86_64/aarch64, MIT. Rust source build includes Vulkan/OpenBLAS/audio/Wayland/X11 deps, bundled wtype/wl-clipboard/curl/ffmpeg wrappers. [flake](https://github.com/anomalyco/hex/blob/v3.4.0/flake.nix), [module](https://github.com/anomalyco/hex/blob/v3.4.0/nix/module.nix), [package](https://github.com/anomalyco/hex/blob/v3.4.0/nix/package.nix).

## Herdr
Official release binary flake `github:herdrdev/herdr-nix` (main). packages.herdr/default; no module. Current package version 0.9.5, upstream assets herdr-linux-x86_64 and herdr-linux-aarch64; binary AGPL-3.0-or-later, packaging MIT. No heavy source Rust/Zig build needed. [flake](https://github.com/herdrdev/herdr-nix/blob/main/flake.nix), [package](https://github.com/herdrdev/herdr-nix/blob/main/package.nix).

## ArtCraft
Community flake `github:Hy4ri/artcraft-flake` (main), distinct from official launcher. packages.default is symlinkJoin containing all 17 apps below. Extra packages.craft-anything-full bundles Ghidra, excluded from default. No modules. x86_64-linux/aarch64-linux, MIT + Apache2, release binaries autoPatchelf. [flake](https://github.com/Hy4ri/artcraft-flake/blob/main/flake.nix), [versions](https://github.com/Hy4ri/artcraft-flake/blob/main/version.json), [package](https://github.com/Hy4ri/artcraft-flake/blob/main/package.nix).

App outputs: anicraft, cadcraft, craft-anything, deckcraft, designcraft, effectcraft, figcraft, filmcraft, gridcraft, lightcraft, materialcraft, pdfcraft, photocraft, soundcraft, texturecraft, vectorcraft, wordcraft.

Official launcher `github:storytold/craft-launcher` (main), packages.default only, executable artcraft-launcher; flake explicitly experimental and currently source build. Uses latest Rust overlay in dev shell but package uses pkgs.rustPlatform, allowBuiltinFetchGit=true for git Cargo dependencies. No NixOS module. Keep own nixpkgs unstable. [flake](https://github.com/storytold/craft-launcher/blob/main/flake.nix). Launcher may manage mutable installations itself; suite flake provides declarative applications independently.

## Helium
No official Nix flake exists in imputnet/helium or imputnet/helium-linux (verified flake.nix 404 on main). Upstream official README lists AppImage/tarball, Debian, Fedora; Nix packages are third party. Current stable Linux release 0.21.2.1. Can use official pinned AppImage and appimageTools.wrapType2; GPL-3.0 plus inherited Chromium licenses, x86_64 and arm64. [official packaging README](https://github.com/imputnet/helium-linux/blob/main/README.md), [release](https://github.com/imputnet/helium-linux/releases/tag/0.21.2.1).

- https://github.com/imputnet/helium-linux/releases/download/0.21.2.1/helium-0.21.2.1-arm64.AppImage hash `sha256-Ih+xUYoEXODxz049NFnnrYDl5WZsGy6a8fhuH068YCg=`
- https://github.com/imputnet/helium-linux/releases/download/0.21.2.1/helium-0.21.2.1-x86_64.AppImage hash `sha256-IdP+SyvmN+uT/eogjWsG1/6feO6MF9gP/57SM3AsBmo=`

## OpenCode v2
Use v2.2.7 stable (Nov 10). GitHub `/releases/latest` deliberately points at v1 to preserve v1 updater; query explicit v2 release instead. Upstream flake source package can build at tag, but binaries below avoid bulky source dependency build. Main branch dev unreleased should not be input. [release](https://github.com/anomalyco/opencode/releases/tag/v2.2.7), [API metadata](https://api.github.com/repos/anomalyco/opencode/releases/tags/v2.2.7), [explanation of v1 latest](https://github.com/anomalyco/opencode/issues/57675).

- https://github.com/anomalyco/opencode/releases/download/v2.2.7/opencode-desktop-linux-arm64.AppImage hash `sha256-7kkXFwxSh0FtsOW153V2clotVOKsZfMCr/3DIiqkTgU=`
- https://github.com/anomalyco/opencode/releases/download/v2.2.7/opencode-desktop-linux-x86_64.AppImage hash `sha256-ilRwn95uWWSXBZ+rYWK1Ix7fJu1hL/HSPQsdUXgo/tA=`
- https://github.com/anomalyco/opencode/releases/download/v2.2.7/opencode-linux-arm64.tar.gz hash `sha256-wWggV/CBXLKr3W4AMF8RRuuvHBZ/AzXNt03cgACBIOc=`
- https://github.com/anomalyco/opencode/releases/download/v2.2.7/opencode-linux-x64.tar.gz hash `sha256-iabO4ie1S8ARF5xSil5jF2AyRisaXiFyO2FoAc3cLKc=`

Hashes above verified from immutable GitHub release asset API digest fields, no invented placeholders. CLI tarball contains opencode binary; use autoPatchelfHook with stdenv.cc.cc.lib as needed. Desktop wrap via appimageTools; preserve Wayland/Ozone flags via wrapper if needed. OpenCode MIT.

Additional verified official OpenCode release flake: `github:anomalyco/opencode/v2.2.7` exports packages.default/opencode and packages.opencode-desktop, overlays.default, no NixOS module. Its nix/node_modules.nix reads committed nix/hashes.json, so no placeholder hash required for normal builds. CLI installs opencode and opencode2 alias, wraps ripgrep and Wayland library paths; desktop installs ai.opencode.desktop ID, opencode-desktop executable, uses pinned/fallback Electron source derivation, bundles same CLI. Own nixpkgs-unstable recommended (models-dev dependency, current bun). [release flake](https://github.com/anomalyco/opencode/blob/v2.2.7/flake.nix), [CLI](https://github.com/anomalyco/opencode/blob/v2.2.7/nix/opencode.nix), [desktop](https://github.com/anomalyco/opencode/blob/v2.2.7/nix/desktop.nix), [node modules](https://github.com/anomalyco/opencode/blob/v2.2.7/nix/node_modules.nix).

Herdr binary flake verified current main commit `602c88543e53f33273ea913b774dfea0a812ac12` (version 0.9.5). Official launcher latest release v0.19.2; consider explicit release-tag input if flake present there instead of current main.
