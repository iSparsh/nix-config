# nix-config

Personal NixOS configurations for a home server and workstation, using the
dendritic pattern, flake-parts, and Hjem.

Automatically discovered `*.mod.nix` files contribute to named profiles. Hosts
receive the shared desktop, application, development, AI, shell, font, and theme
profiles by default; the server also receives Jellyfin and Immich.

- [Shared software, sources, and configuration boundaries](docs/shared-setup.md)
- [Install the laptop and onboard its hardware](docs/install.md)
- [Architecture and adding hosts](docs/architecture.md)
- [Agent instructions](AGENTS.md)
- [Initial upstream research](docs/research.md)

```sh
nix fmt
nix flake check
bash scripts/check-profiles.sh
```

Dependencies are pinned in `flake.lock`; custom release assets are pinned in
`packages.json`. Scheduled automation proposes checked update pull requests.
No installed machines are registered yet. The complete server and workstation
profiles are evaluated with synthetic fixtures, and actual hardware files are
required before deployment. See the installation guide for the first-boot steps.
