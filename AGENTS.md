# Repository rules

- Use the dendritic pattern: each `*.mod.nix` file is a flake-parts module organized around one feature. Read `docs/architecture.md` before changing composition.
- The flake discovers `*.mod.nix` files automatically. Do not manually import shared modules, including named shared-module imports in hosts. Contribute to `flake.modules.nixos.<profile>`; select profiles through `fleet.hosts.<name>.profiles`. The central host constructor handles composition.
- Local supporting imports (such as generated hardware configuration) are allowed. Supporting files use ordinary `.nix` names, not `.mod.nix`. Register upstream integrations once in the shared base.
- Use Hjem, not Home Manager. Discovering a feature must not activate it on every host. Add it to the intended profile; reserve `base` for settings wanted everywhere.
- Never enumerate or broadly search `/nix/store` or equivalent locations. Prefer `nix flake archive --json`, then inspect specific returned input paths in separate commands.
- Use nix3 commands (`nix build/eval/develop/shell/run/flake`), not legacy Nix commands or channels. Use `nixos-rebuild` for system activation. Keep dependencies pinned; update inputs intentionally.
- Separate unrelated configuration sections with blank lines. Run `nix fmt`, `nix flake check`, and build affected real host configurations when feasible. Report which checks ran; stage new files explicitly before evaluating a Git-backed flake.
- Preserve actual hardware settings and each host's initial `system.stateVersion`. Keep credentials out of tracked plaintext. Do not invent installation facts or activate a host merely to validate changes.
