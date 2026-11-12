# NixOS repository architecture evidence

Verified 2026-11-12 against GitHub REST repository metadata, default-branch recursive Git trees, README files and source files. Star counts are popularity signals, not compatibility or quality scores. No external writes performed.

## Verified popularity

| Repository | GitHub stars | Relevant evidence |
|---|---:|---|
| [hercules-ci/flake-parts](https://github.com/hercules-ci/flake-parts) | 1,518 | Established flake-output composition library; does not itself eliminate manual module imports. |
| [mightyiam/dendritic](https://github.com/mightyiam/dendritic) | 674 | Pattern documentation, not a framework; current definition permits plain lib.evalModules as well as flake-parts. |
| [denful/den](https://github.com/denful/den) | 651 | Aspect/context framework; current source has Hjem integration. |
| [snowfallorg/lib](https://github.com/snowfallorg/lib) | 627 | Convention-based discovery; current README calls for maintainers and says effectively unmaintained. |
| [denful/import-tree](https://github.com/denful/import-tree) | 359 | Former vic/import-tree redirects here; dependency-free recursive importer usable with plain NixOS modules. |
| [mightyiam/infra](https://github.com/mightyiam/infra) | 210 | Real infrastructure repository where dendritic originated; automatically imports top-level modules. |
| [NotAShelf/nyx](https://github.com/NotAShelf/nyx) | 437 | Archived; current GitHub snapshot uses Home Manager, not Hjem. |
| [feel-co/hjem](https://github.com/feel-co/hjem) | 711 | Home-file management integrated with NixOS. |
| [fufexan/dotfiles](https://github.com/fufexan/dotfiles) | 1,155 | Popular actual system/home configuration; description explicitly identifies Home Manager. |
| [Aylur/dotfiles](https://github.com/Aylur/dotfiles) | 3,101 | Popular desktop config; stars alone do not make it suitable for server/workstation architecture. |

Counts came from https://api.github.com/repos/OWNER/REPO stargazers_count fields, not search ranking or approximate rendered counts. API also verified Nyx archived=true. Stars span different project categories and must not be treated as a head-to-head architectural ranking.

## Import requirements and simplest recommendation

**Recommendation (inference): plain NixOS modules plus one recursive import of a shared module tree per host, with typed custom options controlling optional features.** Keep host/hardware files outside the shared auto-import tree. Import Hjem's external NixOS module once in the common system constructor. Shared feature modules can then write both system options and hjem.users.<name> options in the same NixOS evaluation. No separate home-module evaluation or flake-parts layer is required for this setup.

[import-tree README](https://github.com/denful/import-tree/blob/main/README.md) explicitly supports NixOS, nix-darwin, Home Manager, flake-parts and other module-system users, with no runtime dependencies. Paths containing /_ are excluded by default. This permits a single shared-directory discovery operation and local private helper files/directories. Explicit support imports must remain under an excluded helper directory (or be filtered), otherwise auto-import may evaluate supporting expressions as modules or import them twice. Ordinary .conf/.lua assets are not .nix modules.

Automatic discovery must be distinguished from activation: adding an optional service module should register its options and mkIf configuration; a host opts into it by setting its option. Common defaults can be mkDefault. Do not choose imports conditionally based on config, because that creates module-discovery recursion. All imported feature configurations need to be gated where host-specific options, secrets or packages are absent.

The [dendritic definition](https://github.com/mightyiam/dendritic/blob/master/README.md) adds a top-level configuration storing lower-level modules as option values. Auto-importing those top-level files does not automatically eliminate lower-level composition imports. Its own section on lower-level module name proliferation warns that giving every feature a distinct name creates long imports lists requiring edits for each new feature. Current definition explicitly does not require flake-parts. Its recommendation against enable options is the author's architectural preference, not a NixOS rule and not binding on the user's stricter automatic-discovery requirement.

[mightyiam/infra outputs.nix](https://github.com/mightyiam/infra/blob/master/outputs.nix) verifies import-tree integration and exclusion of .pkg.nix files. [modules/nixos/pc.nix](https://github.com/mightyiam/infra/blob/master/modules/nixos/pc.nix) illustrates named deferred modules, staticModules composition and generated imports. This is a good learning example, with more abstraction than the recommended starting point.

[Den Hjem integration source](https://github.com/denful/den/blob/main/modules/aspects/batteries/hjem.nix) registers the hjem class, obtains the external module from inputs.hjem and forwards user configuration to hjem.users.<user>. Den is therefore an actually compatible optional alternative when context-aware cross-host/user routing becomes worth its added concepts. It should not be described as required for Hjem or a small multi-host repo.

[Hjem README](https://github.com/feel-co/hjem/blob/main/README.md) describes minimal file management, not a comprehensive application-module collection; it supports per-user files, generators and XDG files in a NixOS module. Keep native application config files next to the feature and use Hjem to link/generate them. Wrapper libraries can complement this for applications accepting config flags, but they solve application configuration packaging rather than repository import discovery.

## Correcting misleading candidates

[Nyx README](https://github.com/NotAShelf/nyx/blob/main/README.md) says the public configuration was abandoned as of August 2024. [Nyx flake](https://github.com/NotAShelf/nyx/blob/main/flake.nix) still includes Home Manager and imports ./parts and ./hosts explicitly; its tree has no Hjem files. It is historical architecture inspiration, **not a verified current public Hjem configuration**. NotAShelf co-maintaining Hjem is not proof that this archived snapshot uses Hjem.

[Snowfall README](https://github.com/snowfallorg/lib/blob/main/README.md) starts with a maintainer call and its maintenance caveat. Avoid presenting this as an uncomplicated new-project recommendation based only on its 627 stars.

The guessed RAF-OS/wrappers repository returned 404. Do not cite it as verified. Known wrapper libraries discovered: [Lassulus/wrappers](https://github.com/Lassulus/wrappers) and [nix-community/nix-wrapper-modules](https://github.com/nix-community/nix-wrapper-modules). Their role is distinct from whole-repository composition.

## AGENTS.md verification

Inspected every path in each complete recursive Git tree on the current default branch. No AGENTS.md exists anywhere in mightyiam/infra (310 tree entries), mightyiam/dendritic, denful/import-tree, hercules-ci/flake-parts, snowfallorg/lib, NotAShelf/nyx, feel-co/hjem or fufexan/dotfiles. This is absence at the inspected branch/time, not a historical assertion. Do not claim these popular configurations prove AGENTS.md conventions.

[denful/den/AGENTS.md](https://github.com/denful/den/blob/main/AGENTS.md) does exist and was read. It documents the real repository layout, entity/aspect/class model, pipeline, formatting/CI commands, testing traps, explicit staging, code conventions and debugging. It is a library development guide, not a ready-made policy for a small personal configuration. Useful transferable structure: short architecture map, ordinary edit workflow, exact validation commands, invariant rules and known pitfalls.

## Community evidence, including disagreement

[How do you structure your NixOS configs?](https://discourse.nixos.org/t/how-do-you-structure-your-nixos-configs/65851) includes drupol describing adoption, vic explaining his real implementation, a user reporting confusion, and replies advocating simpler configurations. This establishes community use and a real tradeoff, not broad consensus. [Vic's explanation](https://discourse.nixos.org/t/how-do-you-structure-your-nixos-configs/65851/8) motivates feature-oriented files spanning module classes. Its 2025 flake-parts-specific description predates the broader current dendritic definition.

[The author's April 2026 response](https://discourse.nixos.org/t/the-dendritic-pattern-in-response-to-comments-in-how-to-define-the-default-package-for-a-nixos-module-in-a-nix-flake/77326) records prominent contributors questioning the pattern's value and the author clarifying that flakes/flake-parts are optional. It should inform candid tradeoff framing rather than a popularity contest.

[Den gradual migration discussion](https://github.com/denful/den/discussions/151) demonstrates an actual request to integrate with an existing flake and the author's separation of import-tree from the framework. The exact example is older API; use current source for implementation.
