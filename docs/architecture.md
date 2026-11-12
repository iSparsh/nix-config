# Proposed architecture

Status: proposed, pending owner review.

## Recommendation

Use one flake with named NixOS host outputs, ordinary NixOS modules, Hjem, and import-tree for automatic discovery of shared NixOS modules. Begin without Den or flake-parts. Those are useful frameworks, but neither is required for the initial two-host configuration.

Shared modules are available to both hosts. Optional features declare enable options and guard their settings with `lib.mkIf`. Hosts select behavior through options rather than importing shared feature files. Availability and activation are separate: discovering gaming configuration does not install Steam on the server.

## Planned layout

```text
flake.nix                  # dependencies, discovery, named host outputs
flake.lock                 # pinned dependency revisions
AGENTS.md                  # maintenance conventions
hosts/
  home-server/
    configuration.nix      # identity, feature choices, installation settings
    hardware-configuration.nix
  workstation/             # added when migration begins
modules/                   # auto-discovered NixOS modules only
  base.nix                 # deliberately shared system defaults
  features/
    gaming.nix
    backups.nix
  services/                # added for chosen server services
  home/                    # NixOS modules configuring hjem.users
files/                     # native dotfiles and local supporting data
docs/
  architecture.md
  research.md
.github/workflows/         # validation once actual configs exist
```

Directory names are conventions, not a second configuration language. Keep host hardware outside shared module discovery. Import-tree is wired once in host composition; upstream Hjem integration is also registered centrally. Local hardware/supporting imports remain permitted.

For illustration, the server could set `my.features.backups.enable = true`, while the workstation sets `my.features.gaming.enable = true`. Neither feature exists yet; exact choices follow the owner's requirements. Shared base settings should contain only behavior deliberately wanted on every host.

Hjem manages native home files. Use standard NixOS package and service options where appropriate. Hjem's per-program companion ecosystem can be considered later rather than added by default.

## Workflow

1. Start from the installed server's generated configuration and hardware facts. Match its installed release initially and preserve its initial stateVersion.
2. Add the smallest useful base, Hjem integration, and the services the owner requests.
3. Pin dependencies and add formatting plus checks of actual host configurations. Validate disabled optional features as well as enabled ones.
4. Build before activation. Document commands for the server and later workstation separately.
5. Add the workstation with its own hardware configuration, reusing the existing shared modules and home settings.

The shared lock file gives both hosts the same dependency revisions at a given commit. Activation is independent: committing or pulling changes does not update either running system automatically. Different stable/unstable inputs can be added later if workstation requirements justify them.

## Alternatives considered

- Den: a community-used framework with substantive agent documentation and Hjem support, but introduces aspects, entities, and policies beyond ordinary NixOS options. Reconsider if cross-host composition becomes difficult.
- Full dendritic layout: organizes multiple module classes by feature and often uses flake-parts. Valuable if the repository grows to manage packages, development environments, and more platforms. Automatic discovery alone does not guarantee compliance with the prohibition on manual shared-module imports.
- Snowfall Lib: established adoption, but its current upstream maintenance notice makes it a poor default for a new repository.

## Information needed for the server

Collect the installed release, generated configuration files, username and hostname, storage layout and encryption choices, network connection, SSH access requirements, lid/suspend preferences, desired services, and backup destination. Add details incrementally as the owner supplies them; do not assume that a fresh install should be repartitioned.
