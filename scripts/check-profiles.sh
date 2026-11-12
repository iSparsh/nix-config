#!/usr/bin/env bash
# Evaluate complete synthetic systems without registering hardware or deploying.
set -euo pipefail
cd "$(dirname "$0")/.."
fixture_dir=$(mktemp -d)
trap 'rm -rf "$fixture_dir"' EXIT
cp flake.nix flake.lock packages.json "$fixture_dir/"
cp -R modules scripts themes "$fixture_dir/"
cp tests/hosts.nix "$fixture_dir/validation.mod.nix"

for host in check-workstation check-server; do
  nix --extra-experimental-features "nix-command flakes" eval --no-update-lock-file --raw "path:$fixture_dir#nixosConfigurations.$host.config.system.build.toplevel.drvPath"
  echo
 done

nix --extra-experimental-features "nix-command flakes" eval --no-update-lock-file --json "path:$fixture_dir#nixosConfigurations" --apply '
  hosts:
  assert hosts.check-server.config.services.jellyfin.enable;
  assert hosts.check-server.config.services.immich.enable;
  assert hosts.check-server.config.services.postgresql.enable;
  assert hosts.check-server.config.services.redis.servers.immich.enable;
  assert !hosts.check-workstation.config.services.jellyfin.enable;
  assert !hosts.check-workstation.config.services.immich.enable;
  assert hosts.check-server.config.services.tailscale.enable;
  assert hosts.check-server.config.services.geoclue2.enable;
  assert hosts.check-server.config.virtualisation.docker.enable;
  assert hosts.check-server.config.programs.nix-ld.enable;
  assert hosts.check-server.config.programs.dms-greeter.configHome == null;
  assert hosts.check-server.config.programs.dms-greeter.configFiles == [];
  { server = "passed"; workstation = "passed"; }
'
