# NixOS Config (Dendritic)

Single-host NixOS flake configuration for `taipei-linux` with a custom installer ISO and Home Manager.

## Requirements
- NixOS 25.11
- `nix-command` and `flakes` enabled

## Build
Use the Makefile targets for the normal build workflow:

```sh
make check
make build-iso
make iso-path
make iso-sha
```

Important: this custom ISO is not Secure Boot signed. Disable Secure Boot in firmware before booting it.

The ISO is produced at:

```sh
./result/iso/*.iso
```

## Install
1. Boot the custom ISO.
2. Partition target disks.
3. If using LUKS for root, ensure the encrypted root partition has label `cryptroot` (or update `modules/nixos/boot-tpm.nix`).
4. Mount target filesystems under `/mnt`.

Example mount flow (adjust devices/filesystems):

```sh
lsblk -f
sudo mount /dev/<root-partition> /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/<boot-partition> /mnt/boot
sudo mkdir -p /mnt/boot/efi
sudo mount /dev/<efi-partition> /mnt/boot/efi
# Optional swap:
sudo swapon /dev/<swap-partition>
```

For LUKS root:

```sh
sudo cryptsetup open /dev/<luks-partition> cryptroot
sudo mount /dev/mapper/cryptroot /mnt
```

Verify:

```sh
findmnt /mnt
```

5. Start `Install Taipei Linux (Flake)` from the app menu (or run `sudo install-taipei-linux`).
6. The script copies this repo to `/mnt/etc/nixos`, generates `hosts/taipei-linux/hardware-configuration.nix`, and runs:

```sh
nixos-install --flake /mnt/etc/nixos#taipei-linux
```

7. Reboot.

## Repo-Switch
After first boot, clone this repository to your user directory (for example `~/src/nixos-config`) and run the following commands from inside that clone. This switches `/etc/nixos` to that repo so you can keep iterating there:

```sh
make post-install-all
```

Step-by-step equivalent:

```sh
make post-install-backup
make post-install-copy-hw
make post-install-link
make post-install-switch
make post-install-cryptenroll
```

`post-install-all` includes TPM enrollment via `systemd-cryptenroll` using `/dev/disk/by-partlabel/cryptroot` by default.

Daily operations:

```sh
make switch
make test-switch
```

Optional one-time Codex install (via Homebrew helper):

```sh
install-codex
```

## Add a new host
1. Create `hosts/<new-host>/default.nix` and `hosts/<new-host>/hardware-configuration.nix`.
2. Add it under `nixosConfigurations` in `flake.nix`.
3. Rebuild:

```sh
sudo nixos-rebuild switch --flake .#<new-host>
```

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
