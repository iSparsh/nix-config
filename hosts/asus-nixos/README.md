# asus-nixos

Intel x86_64 server laptop, user `sparsh`, initial NixOS state version `26.05`.
The supplied hardware file retains its Btrfs root/home/nix mounts, EFI partition,
and kernel modules. The shared Limine bootloader uses the existing `/boot` mount.

This host selects every shared profile plus `server`. Deploying it replaces the
installer's GNOME/GDM session with Hyprland/Dux while retaining locale, time zone,
latest-kernel choice, CUPS, administrator membership, and the existing password.

## First deployment

If Git is not installed, open a temporary shell:

```sh
nix --extra-experimental-features 'nix-command flakes' shell nixpkgs#git
```

The repository is public; no GitHub authentication is required:

```sh
git clone https://github.com/iSparsh/nix-config.git ~/nix-config
cd ~/nix-config
```

If the checkout already exists, use `git pull --ff-only` inside it. Before the
first deployment, back up `/etc/nixos` once to an unused backup path:

```sh
sudo cp -a /etc/nixos /etc/nixos.before-nix-config
```

## Memory bootstrap

This laptop has about 2.7 GiB usable RAM. Before the first large build, create
disk-backed swap on its Btrfs root filesystem. Check that at least 8 GiB is free:

```sh
df -h /
sudo btrfs filesystem mkswapfile --size 8G /swapfile
sudo swapon --priority 10 /swapfile
swapon --show
```

Create the file only once; if `/swapfile` already exists, inspect it rather than
recreating it. The repository makes this 8 GiB swapfile persistent, adds zram,
and limits Nix to one concurrent build with one requested core per build. Swap
helps with memory pressure but does not guarantee large source builds will fit.

Then build and install for the next boot. The explicit limits apply before the
repository settings have been activated:

```sh
sudo nixos-rebuild build --flake .#asus-nixos --max-jobs 1 --cores 1
sudo nixos-rebuild boot --install-bootloader --flake .#asus-nixos --max-jobs 1 --cores 1
sudo reboot
```

The build does not activate changes. The boot command installs Limine and prepares
the next boot while leaving the current session running. Use this checkout and
`--flake .#asus-nixos` for later rebuilds. See [maintenance](../../docs/maintenance.md).

## First login and accounts

Select the Hyprland session. Super+Return opens foot, Super+B Helium, Super+E
Dux Files, and Super+Space the launcher. Dux settings/plugins start from upstream
defaults; select the available Victus Graphite theme when setting up the shell.
See [appearance boundaries](../../docs/shared-setup.md#user-configuration-and-appearance).

Run `sudo tailscale up` and authenticate. GitHub, Bitwarden, and AI tool logins
are separate owner-managed steps; none are necessary to build the public config.

## Media services

| Service | Address | Initial setup |
|---|---|---|
| Jellyfin | `http://<laptop-ip>:8096` | Create an administrator and select media folders |
| Immich | `http://<laptop-ip>:2283` | Create the first administrator and configure photo uploads |

Use the LAN address or the authenticated Tailscale address/MagicDNS name. The host
firewall opens these ports; router forwarding and a public reverse proxy are not
configured. Immich's PostgreSQL, Redis, machine learning, users, and startup are
configured automatically. State/media defaults are `/var/lib/jellyfin` and
`/var/lib/immich`. Immich uses a maintained package from the pinned unstable set;
the base operating system remains stable.

The server stays awake when idle or with the lid closed. External media disks need
explicit mounts and permissions. Hardware transcoding and a backup destination are
follow-up setup. Immich recovery needs both its database and original media.
