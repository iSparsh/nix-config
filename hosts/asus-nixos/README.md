# asus-nixos

Installed Intel x86_64 laptop, primary user `sparsh`, NixOS state version `26.05`.
Hardware configuration was supplied by the owner and retains the installed Btrfs
root/home/nix mounts, EFI partition, and kernel modules. No disks are repartitioned.

The hostname is `asus-nixos`. The host selects all shared profiles plus `server`.
Limine is selected by the shared base for this laptop and the future workstation.
This replaces the installer's systemd-boot setting; the EFI mount remains `/boot`.
The installed user's password is preserved through mutable user management.

The installer GNOME/GDM configuration is replaced by Hyprland/Dux. Existing locale,
time zone, latest-kernel choice, CUPS, and user administrator membership are retained.
Hardware video acceleration and media-library disk mounts still need actual device
and storage details before enabling them.

## First deployment on the laptop

The repository is private. Authenticate GitHub as your normal user first. If Git
and gh are not installed, start a temporary shell:

```sh
nix --extra-experimental-features 'nix-command flakes' shell nixpkgs#git nixpkgs#gh
```

Then:

```sh
gh auth login
gh repo clone iSparsh/nix-config ~/nix-config
cd ~/nix-config
sudo cp -a /etc/nixos /etc/nixos.before-nix-config
sudo nixos-rebuild build --flake .#asus-nixos
sudo nixos-rebuild boot --install-bootloader --flake .#asus-nixos
sudo reboot
```

The first command builds without activating. The boot command installs Limine and
sets up the next boot while leaving the current graphical session running until
reboot. The backup path above should be unused; if you already made that backup,
keep it rather than copying into it again. Always use `--flake .#asus-nixos` from
this checkout for future rebuilds; the installer configuration is not the source
of truth after adopting the repository.

After boot, log into the Hyprland session. Useful initial shortcuts: Super+Return
for foot, Super+B for Helium, Super+E for Dux Files, Super+Space for the launcher.
Dux settings and plugins start from upstream defaults; Victus Graphite is available
for selection without copying the workstation's shell settings.

Authenticate Tailscale with `sudo tailscale up`. Jellyfin is on port 8096 and Immich
on port 2283 of the laptop's LAN or Tailscale address. Create the application admin
accounts in their setup pages. See [the service guide](../../docs/install.md).
