# Dendritic architecture

The repository uses flake-parts with automatic discovery of `*.mod.nix` files. Each discovered file is a top-level flake-parts module organized around a feature. It contributes lower-level NixOS configuration through `flake.modules.nixos.<profile>` or defines other flake outputs such as formatting and checks.

## Layout

```text
flake.nix                    # inputs and automatic *.mod.nix discovery
flake.lock                   # pinned revisions
modules/
  infrastructure/
    hosts.mod.nix            # host schema and central composition
    tooling.mod.nix          # formatter and integration checks
  profiles/
    base.mod.nix             # Hjem integration and shared Nix CLI settings
hosts/
  README.md                  # actual host files added after installation
AGENTS.md                    # repository-specific maintenance rules
.github/workflows/check.yml  # formatting and flake checks
```

Discovery scans the repository, so a feature file can move between directories without an import-list edit. Only `.mod.nix` files participate. Supporting expressions, generated hardware configuration, and native dotfiles are not top-level modules and must use other names.

## Features and profiles

See [the approved shared setup](shared-setup.md) for the owner's application,
appearance, and service requirements and current implementation status.

Multiple files can contribute to the same deferred NixOS module. For example, a future `modules/steam.mod.nix` could contain:

```nix
{
  flake.modules.nixos.gaming = {
    programs.steam.enable = true;
    # Add the required unfree-package policy when implementing gaming.
  };
}
```

Another file can contribute related gaming settings to `flake.modules.nixos.gaming`. The module system merges those contributions. This is how features remain together without creating one import list per host. A feature may also contribute packages, checks, or other module classes when needed.

Discovery makes profiles available; it does not install their contents on every host. `base` is always included. Other profiles are selected by name in each host's declaration. Profile names are open-ended, so adding a profile needs no registry edit. Unknown profile names produce an evaluation error.

This differs from RGBCube's ncc branch: both use flake-parts and `.mod.nix` discovery, but this repository centrally composes profiles to preserve the rule against manual shared-module imports. It does not replicate ncc's custom library, service framework, or Darwin integration.

## Adding a host

An illustrative `hosts/home-server/home-server.mod.nix`:

```nix
{
  fleet.hosts.home-server = {
    system = "x86_64-linux";
    profiles = [ ]; # Select additional profiles after implementing them.

    module = {
      imports = [ ./hardware-configuration.nix ];

      # Copy installation-specific settings from the installed machine,
      # including its original system.stateVersion and bootloader settings.
    };
  };
}
```

This is a structural example, not an installable configuration. The repository intentionally has no real host outputs until actual installation facts are supplied. Preserve the installer's generated `configuration.nix` and `hardware-configuration.nix`.

The central constructor adds `base`, the host-local module, hostname, and selected profiles. Host files do not manually import shared modules by path or attribute reference. Host-local hardware/supporting imports are allowed. Hjem's external module is registered once in `base`; home configuration can be contributed to the same profiles through `hjem.users` without Home Manager.

Nixpkgs initially tracks stable `nixos-26.05`; confirm compatibility with the installed server before registering it. Each machine retains its own initial `system.stateVersion`, independent of the input revision. Additional stable/unstable inputs can be introduced deliberately if workstation requirements justify them.

## Validation and deployment

```sh
nix fmt
nix fmt -- --ci
nix flake check
```

The formatter is nixfmt, using its treefmt wrapper. The integration check evaluates the base profile's Nix settings and Hjem registration without constructing a deployable fake machine. The flake exports tooling for x86_64-linux and aarch64-linux; ordinary checks build for the current platform.

Once a real host exists, evaluate and build it before activation:

```sh
nix eval .#nixosConfigurations.home-server.config.system.build.toplevel.drvPath
nix build .#nixosConfigurations.home-server.config.system.build.toplevel
```

On the intended NixOS host, apply its configuration with:

```sh
sudo nixos-rebuild switch --flake .#home-server
```

Stage newly created files explicitly before Git-backed flake evaluation. Do not activate systems as a validation shortcut. CI runs formatting and flake checks; add real host build checks when those outputs exist. Package builds, runtime testing, application state, secrets, and backups remain separate concerns.

Both machines share dependency revisions through `flake.lock`, but activation is independent. A commit or pull does not change either running machine automatically.

## Sources

- [Dendritic pattern](https://github.com/mightyiam/dendritic): feature-oriented top-level modules and merging lower-level module values.
- [flake-parts modules](https://flake.parts/options/flake-parts-modules.html): typed `flake.modules` registry.
- [Hjem](https://hjem.feel-co.org/): user-file management and NixOS integration.
- [Initial research](research.md): historical alternatives and adoption evidence, collected before the owner selected dendritic.
