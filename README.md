# nix-config

Public personal NixOS configurations using the dendritic pattern, flake-parts,
Hjem, and Limine. The server is `asus-nixos`; the workstation is added when it
moves to NixOS.

```sh
git clone https://github.com/iSparsh/nix-config.git ~/nix-config
cd ~/nix-config
```

Cloning and building need no GitHub login. Authenticate applications separately
when using their account features.

- [Deploy asus-nixos and set up its services](hosts/asus-nixos/README.md)
- [Shared software and configuration boundaries](docs/shared-setup.md)
- [Architecture and adding hosts](docs/architecture.md)
- [Validation and updates](docs/maintenance.md)
- [Agent instructions](AGENTS.md)

Hosts receive shared desktop, application, development, AI, shell, font, and theme
profiles. The server also runs Jellyfin and Immich. Dependencies are pinned in
`flake.lock`; custom release assets are pinned in `packages.json`.

The registered hardware configuration belongs to this laptop. Other machines
need their own hardware file, username, and initial `system.stateVersion`.
