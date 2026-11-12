# Shared setup

The owner approved this setup for both the home server and future workstation.
This is an implementation checklist; entries marked planned are not configured yet.

## Implemented

- `base`: Hjem integration, Nix CLI features, and nix-ld compatibility. NixOS's
  default C/C++, TLS, compression, and system libraries are extended with libffi,
  ICU, SQLite, ncurses, readline, and GLib. This does not set global
  `LD_LIBRARY_PATH` or guarantee that every downloaded Linux binary will work.
- `ai-tools`: Nixpkgs Codex and Claude Code, explicitly chosen by the owner.
  Their versions follow the pinned Nixpkgs revision. They are not installed or
  updated through Bun, npm, or upstream installation scripts.
- Unfree packages are allowed by name through `local.allowedUnfreePackages`.
  Selected profiles extend the list; it is not a blanket allowance.

No real host is registered yet, so these modules have not been activated on a
machine. The `ai-tools` profile currently contains only Codex and Claude Code.

## Planned profiles

| Profile | Scope |
|---|---|
| `shell` | Recreate the current zsh behavior declaratively: history, completion, keybindings, autosuggestions, highlighting, fzf, Starship, zoxide, and portable aliases. Adapt Arch-only paths and aliases; do not copy `.zshrc` wholesale. |
| `desktop` | Hyprland, upstream Dux Shell/Search/Files/Greeter, portals, audio, clipboard, and GeoClue with location-provider and session-agent integration. |
| `apps` | Helium, Chromium, gh, Zed, Neovim, foot, Obsidian, mpv, VLC, Bitwarden CLI/GUI, GNOME Calculator. |
| `development` | Node/npm, Bun, pnpm, Rust/Cargo, uv, common build tools, Playwright and compatible browsers, Docker daemon, Compose v2, Buildx, and user access. |
| `ai-tools` additions | T3 Code, OpenCode v2 CLI/desktop, llama.cpp CLI, Hex, and Herdr. Hex hardware support is confirmed on the current workstation; preserve required runtime integration on NixOS. |
| `appearance` | Ioskeley monospace, JetBrains fallback, Inter sans-serif, Source Serif Pro serif, Apple Color Emoji, and additional glyph coverage. One canonical Victus Graphite palette with application adapters. |
| `connectivity` | Tailscale enabled with appropriate networking integration; authenticate separately. |
| ArtCraft | Review community packaging and upstream launcher. Launcher-installed children remain mutable user applications unless individually packaged through Nix. |

Prefer maintained official upstream flakes with installable packages and published
releases. Use current Nixpkgs, reviewed community flakes, or local packaging as
fallbacks. Codex and Claude Code are explicit Nixpkgs choices.

The baseline should support ordinary one-off user installs through Bun/npm and
other tools using writable directories and nix-ld. This compatibility layer is
separate from how the declared shared applications are installed. Native
extensions and application-specific dependencies may still require development
shells or packaging.

## Appearance boundaries

- Dux gets the Victus Graphite theme made available. Do not port current shell
  settings, plugins, layouts, monitor assignments, or unrelated preferences.
- Zed gets the requested font settings and the Victus Graphite theme; preserve
  unrelated settings and allow application-managed settings to remain writable.
- Obsidian's theme and selected font settings are vault-local; integrate those
  without replacing the vault configuration wholesale.
- Generate theme adapters for Dux, Zed, Obsidian, T3 Code, and foot from common
  palette data, retaining deliberate differences between applications.
- Use a pinned Ioskeley release ZIP where possible rather than vendoring TTFs.
  Do not migrate the existing fontconfig rules; express the requested defaults.

## Host onboarding

Before registering or deploying the server, collect its installer-generated
configuration and hardware files, installed release, username, hostname, and
storage/boot details. Preserve initial `system.stateVersion` and disk identifiers.
Later add server services, backups, lid behavior, and workstation-specific settings
as supplied by the owner. Hardware information is required for host deployment,
not for progressing the shared modules.
