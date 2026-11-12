# nix-config

Personal NixOS configurations for a home server and a future workstation, using Hjem for home configuration.

This repository currently contains the proposed design and maintenance instructions. It does not yet contain an installable system configuration.

- [Proposed architecture](docs/architecture.md)
- [Upstream research](docs/research.md)
- [Agent instructions](AGENTS.md)

Next: agree on the architecture, then add the server's actual installation facts and desired services. Preserve the NixOS installer's generated `configuration.nix` and `hardware-configuration.nix` for that step.
