# nix-config

Personal NixOS configurations for a home server and a future workstation, using the dendritic pattern, flake-parts, and Hjem.

Features live in automatically discovered `*.mod.nix` files. Each file contributes to named profiles or other flake outputs. Hosts select profiles; one central constructor composes shared modules.

```sh
nix fmt
nix flake check
```

- [Architecture and adding a host](docs/architecture.md)
- [Initial upstream research](docs/research.md)
- [Agent instructions](AGENTS.md)

The flake provides shared Hjem integration, formatting, and validation. No installed hosts are registered yet. Next, add the server's actual installation facts and desired services. Preserve the NixOS installer's generated `configuration.nix` and `hardware-configuration.nix` for that step.
