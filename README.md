# NixOS Config (Dendritic)

This repo is a dendritic-style NixOS configuration with home-manager.
It currently contains a single host: `taipei-linux`, but is structured to add more hosts later.

## Requirements
- NixOS 25.11
- `nix-command` and `flakes` enabled (already set in the config)

## Structure
- `flake.nix`: entry point and host list
- `hosts/<hostname>/`: host-specific config and hardware
- `modules/nixos/`: reusable system modules
- `home/<username>/home.nix`: home-manager config for users
  - Plasma defaults are set via plasma-manager in home-manager

## First-time setup
1. Generate hardware config on the target machine:
   ```sh
   sudo nixos-generate-config --show-hardware-config
   ```
2. Replace `hosts/taipei-linux/hardware-configuration.nix` with the output.
3. Update LUKS UUID in `modules/nixos/boot-tpm.nix`:
   - Replace `REPLACE-WITH-LUKS-UUID` with your actual LUKS UUID (from `blkid`).
4. Enroll the LUKS volume with TPM2:
   ```sh
   sudo systemd-cryptenroll --tpm2-device=auto /dev/disk/by-uuid/<LUKS-UUID>
   ```

## Build and switch
```sh
sudo nixos-rebuild switch --flake .#taipei-linux
```

## Custom installer ISO (GUI + flake apply)
Build a graphical ISO that includes this repo and a launcher named `Install Taipei Linux (Flake)`:
```sh
nix build .#taipei-installer-iso
```

ISO output path:
```sh
./result/iso/*.iso
```

Install flow:
1. Boot the custom ISO.
2. Use the normal graphical installer to partition and mount target disks.
3. Open `Install Taipei Linux (Flake)` from the app menu (or run `sudo install-taipei-linux` in a terminal).
4. The script copies this repo to `/mnt/etc/nixos`, generates `hosts/taipei-linux/hardware-configuration.nix`, and runs `nixos-install --flake /mnt/etc/nixos#taipei-linux`.
5. Reboot.

## Fedora KDE defaults
- Plasma defaults (Breeze, Noto fonts) are set in `home/johnbarney/home.nix`.
- KDE app set is included in `modules/nixos/desktop-kde.nix`.
- Flatpak is enabled and Flathub is added on boot via `modules/nixos/base.nix`.
- Fedora wallpaper is configured for both Plasma and SDDM in `modules/nixos/fedora-artwork.nix`.
  - If the wallpaper URL changes, re-prefetch and update its hash in `modules/nixos/fedora-artwork.nix`.

## Add a new host
1. Create `hosts/<new-host>/default.nix` and `hosts/<new-host>/hardware-configuration.nix`.
2. Add it under `nixosConfigurations` in `flake.nix`.
3. Rebuild using the new hostname:
   ```sh
   sudo nixos-rebuild switch --flake .#<new-host>
   ```

## Notes
- Plasma 6 is enabled via `services.desktopManager.plasma6.enable`.
- SDDM uses Wayland via `services.displayManager.sddm.wayland.enable`.
- Fedora-like defaults are approximated with common services and KDE apps.

## Disclaimer
- This configuration is provided as-is, without warranty.
- Review hardware, boot, encryption, and networking settings before using on production systems.

## Security
- No secrets are intentionally stored in this repository.
- Do not commit private keys, password files, API tokens, or machine-specific secret material.
- Local secret scanning is configured via `pre-commit` using `gitleaks` in `.pre-commit-config.yaml`.
- Setup:
  ```sh
  nix shell nixpkgs#pre-commit -c pre-commit install
  nix shell nixpkgs#pre-commit -c pre-commit run --all-files
  ```

## License
- MIT. See `LICENSE`.
