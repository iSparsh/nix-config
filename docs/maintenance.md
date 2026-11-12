# Validation and updates

Run commands from the repository checkout. Git-backed flakes include tracked
files, so stage newly added files explicitly before evaluation.

## Validate

```sh
nix fmt
nix fmt -- --ci
nix flake check
bash scripts/check-profiles.sh
nix build --no-link .#nixosConfigurations.asus-nixos.config.system.build.toplevel
```

Flake checks cover shared integration, theme generation, and settings preservation.
The profile script evaluates synthetic server and workstation configurations and
checks their separation, including the shared Limine choice. The final command
builds the real server; it does not activate it. Evaluation alone does not establish
build success or first-boot graphics, audio, firmware, and service behavior.

## Update dependencies

```sh
git pull --ff-only
python3 scripts/update-sources.py
```

The Python command checks official release sources without writing changes. It
uses `gh api`, so authenticate `gh` for local release checks; CI supplies its token. For an
intentional update:

```sh
python3 scripts/update-sources.py --apply
nix flake update
```

Review `flake.nix`, `flake.lock`, and `packages.json`, then validate before committing.
For a targeted flake input update, use `nix flake update <input-name>`. Release-tagged
inputs also need their tag changed; the Python updater handles the configured tags.

The scheduled GitHub workflow proposes validated changes as pull requests. If
repository policy blocks PR creation, it attaches a patch artifact instead. It
never merges or deploys automatically. Authentication is needed to push changes
or manage GitHub resources, not to fetch this public repository.

## Deploy

For the first deployment and bootloader migration, follow the
[asus-nixos guide](../hosts/asus-nixos/README.md). Later, on that laptop:

```sh
cd ~/nix-config
git pull --ff-only
sudo nixos-rebuild boot --flake .#asus-nixos
sudo reboot
```

For changes intended to activate immediately, use `switch` instead of `boot`.
Keep `system.stateVersion` at the host's initial installed value. Application data,
credentials, backups, and database migrations are separate from Git and system
configuration rollback.
