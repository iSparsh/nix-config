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
The installed server is [asus-nixos](hosts/asus-nixos/README.md), with its supplied
hardware configuration and shared Limine bootloader. The workstation is added when
it migrates to NixOS. Complete shared server/workstation profiles also have synthetic
evaluation fixtures. See the host guide for building and the first deployment.
