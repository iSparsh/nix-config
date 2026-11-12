# Architecture

Every `*.mod.nix` file is an automatically discovered flake-parts module organized
around a feature. It can contribute NixOS settings, packages, checks, or development
shells. Other `.nix` files are supporting expressions and are not auto-discovered.

## Composition

Features contribute to `flake.modules.nixos.<profile>`. Multiple files contributing
to one profile merge through the module system. `modules/features/development.mod.nix`,
for example, provides both the development profile and the Playwright dev shell.

`modules/infrastructure/hosts.mod.nix` constructs named systems from `fleet.hosts`:

- `base` is always included and selects Limine, Hjem, and shared system settings.
- `fleet.sharedProfiles` supplies the default optional profiles.
- Each host declares its architecture, primary username, local settings, and any
  profile overrides. `asus-nixos` adds `server` to the shared profiles.
- The central constructor composes shared modules. Hosts do not maintain shared
  file imports or named-module import lists.

Only selected profiles activate. Upstream integrations are registered once in the
profile that owns them. Local imports, such as generated hardware files, are allowed.

## Files

| Location | Purpose |
|---|---|
| `flake.nix`, `flake.lock` | Upstream inputs, pinned revisions, discovery |
| `modules/infrastructure/` | Host construction, package sets, tooling |
| `modules/profiles/` | Shared base settings |
| `modules/features/` | Software, services for user sessions, appearance |
| `modules/services/` | Jellyfin, Immich, and server power behavior |
| `modules/packages/`, `packages.json` | Custom packages and pinned release assets |
| `hosts/asus-nixos/` | Real host settings, hardware, deployment guide |
| `themes/victus-graphite/` | Canonical palette and application templates |
| `scripts/`, `tests/` | Updates, appearance merging, validation fixtures |

The OS uses stable NixOS; a separately pinned unstable package set supplies current
applications. Official upstream flakes retain required dependency pins. Hjem
manages home files; writable application settings receive targeted merges.

## Adding a machine

1. Obtain its generated configuration and hardware files.
2. Add `hosts/<hostname>/<hostname>.mod.nix` declaring `fleet.hosts.<hostname>`.
   Set `system`, `primaryUser`, and `module`; override `profiles` only if necessary.
3. Import the local hardware file inside `module`. Preserve filesystem identifiers,
   EFI settings, users, and initial `system.stateVersion`. Shared Limine replaces
   the installer's bootloader choice.
4. Follow [validation and updates](maintenance.md), build the actual host, then
   deploy on the intended machine.

The flake emits `nixosConfigurations.<hostname>`. Committing or pulling changes
never activates them on a running host.

References: [dendritic pattern](https://github.com/mightyiam/dendritic),
[flake-parts modules](https://flake.parts/options/flake-parts-modules.html),
[Hjem](https://hjem.feel-co.org/).
