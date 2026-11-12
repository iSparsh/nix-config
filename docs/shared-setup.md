# Shared setup

The shared profiles below are implemented and selected by default for each host.
A server additionally selects `server`. No real host is registered until its
installer-generated files are supplied. Package revisions live in `flake.lock`;
custom binary/font release URLs and hashes live in `packages.json`.

| Profile | Implemented contents |
|---|---|
| `base` | Hjem, modern Nix CLI settings, nix-ld with the NixOS defaults plus libffi, ICU, SQLite, ncurses, readline, and GLib. Named unfree-package allowances. |
| `shell` | zsh completion/history/keybindings, autosuggestions, highlighting, fzf, Starship, zoxide, portable aliases, and OpenConnect for the existing VPN alias. Recreated declaratively without copying `.zshrc`. |
| `desktop` | Hyprland/UWSM, official upstream Dux Shell/Search/Files/Greeter, portals, PipeWire audio, clipboard tools, NetworkManager, GeoClue, and session integration. |
| `apps` | Helium, Chromium, gh, Zed, Neovim, foot, Obsidian, mpv, VLC, Bitwarden CLI/GUI, GNOME Calculator. |
| `development` | Node/npm, Bun, pnpm, Rust/Cargo/rustfmt/clippy/rust-analyzer, uv, Python, C/C++ build tools, Git/curl/jq/archive utilities, Playwright with matching browsers, Docker daemon, Compose v2, Buildx, lazydocker, and user access. |
| `ai-tools` | Nixpkgs Codex and Claude Code as explicitly requested; T3 Code, official OpenCode v2 CLI/desktop, Hex, Herdr, and llama.cpp's CLI command without enabling a model server. |
| `appearance` | Ioskeley and JetBrains Nerd Fonts, Inter, Source Serif Pro, Apple Color Emoji, fallback language/glyph fonts, requested fontconfig defaults, Victus Graphite palette and adapters. |
| `connectivity` | Tailscale enabled; owner authenticates separately. |
| `artcraft` | Official launcher plus community Nix-managed WordCraft and PdfCraft. AppImage compatibility for additional launcher-managed apps. |
| `server` | Jellyfin, maintained Immich with PostgreSQL/Redis/machine learning, web firewall ports, and laptop lid/idle settings that keep services running. |

## Package sources

Maintained official flakes are preferred: Dux, Zed, Hex, Herdr, OpenCode v2, and the
ArtCraft launcher. Release tags are used where appropriate. Their required
upstream dependency pins are retained instead of forcing them onto the older
system package set. Hex's upstream flake has a transitive Home Manager input;
this repository does not import or configure Home Manager.

The base OS and Nixpkgs Codex/Claude Code use stable NixOS. A separately pinned
unstable package set supplies current general applications and development tools.
Immich uses that maintained package and PostgreSQL 17 because the older stable
Immich package is marked insecure. The stable NixOS Immich module provides service
and database setup. Insecure packages are not allowed as a workaround.

Helium and the requested Ioskeley/Apple fonts use official releases with verified
hashes. ArtCraft WordCraft/PdfCraft use the reviewed Hy4ri community package flake.
The Tailscale upstream developer flake warns about brittle vendor hashes, so its current Nixpkgs package is used with the native service module. Bun's upstream flake supplies only a development shell.

Other Craft apps installed through the launcher live in the user's writable data;
those installations and updates are not governed by Nix.

## User configuration and appearance

The primary username comes from host onboarding. Hjem manages selected native
files. App settings that need to stay writable are handled by a small merge tool
that changes only the requested fonts and theme keys.

- Dux receives only the available Victus Graphite theme file. No current settings,
  plugins, layouts, monitor assignments, or wallpapers are copied. Select the
  custom theme through Dux when setting up the session.
- Zed receives the current font families and UI/buffer sizes, its Markdown font,
  and Victus Graphite. Unrelated settings are preserved. JSONC comments are not
  retained when a settings merge rewrites the JSON document.
- Obsidian gets its theme and monospace preference in registered vaults, without
  replacing the rest of the vault configuration. On a new installation, create or
  register the vault first. `apply-shared-appearance` can be run manually; a user
  service applies it at login and watches the vault registry for additions.
- T3 Code receives `~/.t3/userdata/themes/victus-graphite.json`. Select the theme in
  Appearance, or run `t3 theme set victus-graphite` when its local environment is
  running. Publishing the file does not start T3 Code or modify its account state.
- foot receives the existing font size, terminal behavior, and Victus colors.
- Shared colors live in `themes/victus-graphite/palette.json`; application-specific
  `.in` templates retain intentional differences while referencing that palette.
- Font defaults are Ioskeley monospace with JetBrains fallback, Inter sans-serif,
  Source Serif Pro serif, and Apple Color Emoji. The old fontconfig is not copied.

## One-off tools and project environments

Writable npm/Bun/pnpm paths and nix-ld support conventional user-level installs.
Native extensions and application-specific dependencies can still need a project
shell or package. The declared applications above are Nix-managed; no installer
scripts or global package downloads run during login or activation.

The `playwright` command uses the packaged driver and matching browsers without
forcing a global browser path on unrelated projects. Project-specific Playwright
versions should use matching browsers in a project development shell.
`nix develop .#playwright` provides the repository's matching Node/driver/browser environment. The shared
Playwright version is recorded at `/etc/nix-config/playwright-version`.

## Remaining machine-specific work

See [installation and first service setup](install.md). We still need actual
hardware/storage/boot settings before host deployment. Owner authentication,
Jellyfin libraries, photo imports, external storage mounts, hardware acceleration,
and a backup destination are performed after that. Nothing has been activated on
the laptop by changing this repository.
