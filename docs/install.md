# Installing the laptop

Use the current stable [graphical ISO](https://nixos.org/download/#nixos) for the
laptop's architecture (normally 64-bit Intel/AMD). Flash it to USB and boot it in
UEFI mode. The desktop used by the live ISO does not determine the installed
system's desktop.

1. Connect to Wi-Fi or Ethernet and launch the graphical installer.
2. Select language, keyboard, and time zone. Create the username you want to keep,
   choose a hostname, and set a password. Automatic login is optional; it is not
   required by this repository.
3. Choose Plasma as a temporary desktop for convenient networking, a browser,
   and transferring the generated files. We will replace its desktop/greeter
   settings with Hyprland and Dux while integrating the installed configuration.
   Do not install both desktop stacks manually.
4. Choose the target disk deliberately. "Erase disk" deletes that disk's existing
   contents; use it only if that is your intended replacement disk. The installer
   can create the partitions; this repository does not repartition disks.
   A normal ext4 installation is sufficient. Disk encryption is optional; a
   passphrase-based encrypted root normally needs local unlock after a reboot.
5. Finish installation, reboot, remove the USB, and confirm networking works.
6. Provide `/etc/nixos/configuration.nix` and
   `/etc/nixos/hardware-configuration.nix`, plus the installed NixOS version,
   hostname, and username. Preserve `system.stateVersion`, bootloader settings,
   and filesystem identifiers. The shared base replaces the installer bootloader
   choice with Limine. No application installation is needed first.

The installed laptop is now registered as `asus-nixos`. Follow its
[deployment guide](../hosts/asus-nixos/README.md) to adopt the repository and install
the shared Limine bootloader. Synthetic validation hosts remain isolated test fixtures.

The shared setup includes Nix, Git, gh, Hjem, all requested applications, fonts,
and service integration. Authentication is performed by the owner after deployment:
Tailscale, GitHub, Bitwarden, AI tools, and other accounts. No credentials are copied
from the workstation or committed to this repository.

## First service setup after deployment

- Jellyfin: `http://<laptop-ip>:8096`. Create its administrator and add media
  library folders through the setup wizard. Its state lives under `/var/lib/jellyfin`.
- Immich: `http://<laptop-ip>:2283`. Create its first administrator account through
  the web setup. PostgreSQL, Redis, machine learning, service users, and startup
  are configured automatically. Media lives in `/var/lib/immich` by default.
- Tailscale: run `sudo tailscale up` and authenticate. Use the assigned address or
  MagicDNS name to reach the same service ports from your tailnet.

The web ports are opened on the machine firewall for LAN/tailnet access. This
repository configures no router forwarding, public domain, public reverse proxy,
or exit-node/subnet-router advertisement. Accounts are still required in the apps.

The server profile keeps the machine awake when idle or with its lid closed.
Hardware transcoding is left at CPU defaults until GPU details are known. Media
on an external disk needs an explicit mount and service permissions; it is not
silently pointed at a guessed disk. The first Immich install uses maintained
packages from the pinned unstable package set because the stable release's older
Immich is marked insecure. The base operating system remains stable.

Backups need a destination supplied later. Immich recovery requires its database
and original media; configuration in Git is not a backup of those files.

## Routine maintenance

```sh
nix fmt
nix flake check
bash scripts/check-profiles.sh
python3 scripts/update-sources.py
```

For an intentional update, run `python3 scripts/update-sources.py --apply`, then
`nix flake update`, stage new files explicitly, and repeat validation. A scheduled
GitHub workflow proposes checked updates as pull requests; repository settings
must permit GitHub Actions to create pull requests for that final step; otherwise
the workflow attaches the proposed patch as an artifact. Updates
are not automatically merged or deployed.

Full profile evaluation checks module composition, package derivations, and
server/workstation separation. It is not a complete system build or a substitute
for first-boot, graphics, audio, and service runtime testing on the laptop.

Sources: [NixOS download](https://nixos.org/download/),
[NixOS installation manual](https://nixos.org/manual/nixos/stable/#sec-installation).
