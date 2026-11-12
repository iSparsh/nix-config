# Working conventions

This repository will manage a home server and a workstation with NixOS and Hjem. Read `docs/architecture.md` before changing module discovery, host selection, or dependency structure. The architecture is proposed until the owner accepts it; do not treat planned hosts as deployable.

## Modules and configuration

- Do not manually import shared modules. Discover shared modules through the central automatic discovery mechanism. Enable optional behavior through declared NixOS options, with optional features disabled by default.
- Imports of local supporting files, such as a host's generated hardware configuration, are fine. Register upstream integration modules such as Hjem once at the composition boundary.
- Keep automatically discovered files in the same module class. Keep helper expressions and supporting data outside discovery, or exclude them explicitly. Discovering a feature must not enable it on every host.
- Use Hjem for user files and preferences. Do not introduce Home Manager.
- Separate unrelated configuration sections with blank lines. Keep related settings together and format with the repository formatter once configured.
- Preserve each installed host's generated hardware configuration and initial `system.stateVersion`; do not invent disk identifiers, hardware settings, or installation facts.

## Nix commands and source inspection

- Never search or enumerate `/nix/store`, including equivalent store locations, broad filesystem searches, globbing, or recursive searches of store roots.
- Prefer `nix flake archive --json` to resolve pinned input source paths. Read only the specific returned input path and relevant files. Use `nix flake metadata --json` for dependency metadata.
- Use modern Nix commands: `nix build`, `nix eval`, `nix develop`, `nix shell`, `nix run`, and `nix flake`. Avoid legacy `nix-build`, `nix-shell`, `nix-env`, and channel-based dependency management. Use `nixos-rebuild` for NixOS activation; it has no direct `nix` subcommand replacement.
- Keep dependency versions pinned in `flake.lock`. Update only intended inputs; do not update dependencies as an incidental part of another change.

## Validation and reporting

- Once tooling exists, run formatting checks and `nix flake check`. Evaluate every affected host, including a host on which a changed feature is disabled.
- For system changes, build the affected host's `config.system.build.toplevel` when feasible. Distinguish formatting, evaluation, build, and runtime verification; report checks that could not run.
- Ensure new files are tracked before evaluating a Git-backed flake. Stage explicit paths.
- Keep credentials and private keys out of tracked configuration. Store secret references or encrypted material with keys provisioned separately.
- Do not activate a host merely to validate a change. Apply changes only to the host the user has asked to configure, following its deployment instructions.
