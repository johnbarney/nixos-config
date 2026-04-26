# NixOS Config (Dendritic)

Public NixOS base flake for reusable desktop modules, profiles, and installer
module code. Host definitions and install artifacts intentionally live in
consumer repos.

## Layout

- `flake.nix` delegates the flake body to `flake/` through `flake-parts`.
- `flake/nixos-configurations.nix` exports the public API.
- `profiles/` composes reusable machine profiles.
- `modules/nixos/` contains shared NixOS modules, including desktop, NVIDIA, TPM unlock, and service configuration.
- `installer/` customizes the live ISO and provides `install-nixos-host`.

## Repo Model

This repo is the public base. It should stay reusable and educational, while
machine-specific state lives elsewhere.

Recommended repo split:

- `nixos-config`: public base with reusable modules, profiles, installer code,
  and no machine-specific hosts.
- `nixos-hosts-template`: public starter repo that shows how to consume this
  base without exposing real machine details.
- A private hosts repo: personal machine definitions, generated hardware
  configs, and private host choices.

This base exposes:

- `nixosModules.default` / `nixosModules.dendritic` for the shared NixOS modules.
- `nixosModules.desktop-nvidia` for the current desktop profile.
- `nixosModules.installer` for the live ISO customizations.
- `lib.mkDendriticHost` for private or template flakes to build hosts from this base.

Start new host repos from `github:johnbarney/nixos-hosts-template`. A public
template repo should keep sanitized placeholder hardware configs. A private
hosts repo should commit real `hardware-configuration.nix` files and any private
host identity. Either kind of consumer can update this public base with:

```sh
nix flake lock --update-input dendritic
```

## Requirements

- Nix with `nix-command` and `flakes` enabled.
- A NixOS-compatible system for host rebuilds.
- Secure Boot disabled when booting the custom ISO; the ISO is not signed.

## Common Commands

```sh
make help
make check
```

Host rebuilds should usually happen from a consumer repo. This public base only
exports reusable modules/profiles.

## Install From a Consumer ISO

Build and boot the installer from a hosts repo, such as
`github:johnbarney/nixos-hosts-template` or a private repo based on it.

1. Partition and mount the target system under `/mnt`.

   For a plain root filesystem:

   ```sh
   lsblk -f
   sudo mount /dev/<root-partition> /mnt
   sudo mkdir -p /mnt/boot/efi
   sudo mount /dev/<efi-partition> /mnt/boot/efi
   sudo swapon /dev/<swap-partition>   # optional
   ```

   For LUKS root, open the volume first:

   ```sh
   sudo cryptsetup open /dev/<luks-partition> cryptroot
   sudo mount /dev/mapper/cryptroot /mnt
   ```

   TPM unlock expects the encrypted root partition at
   `/dev/disk/by-partlabel/cryptroot`. Either set that partition label or update
   `modules/nixos/boot-tpm.nix`.

2. Confirm the mount tree:

   ```sh
   findmnt /mnt
   ```

3. Put a hosts flake at `/mnt/etc/nixos`. For example, clone your private hosts
   repo there, or copy it from another mounted disk.

4. Start `Install NixOS Host (Flake)` from the live desktop menu, or run:

   ```sh
   sudo install-nixos-host
   ```

   To skip the host picker:

   ```sh
   sudo install-nixos-host <host>
   ```

   If the hosts repo is available at a local path, the helper can copy it first:

   ```sh
   sudo install-nixos-host <host> /path/to/hosts-repo
   ```

The installer reads host choices from `/mnt/etc/nixos/hosts`, regenerates
`hosts/<host>/hardware-configuration.nix`, and runs:

```sh
nixos-install --root /mnt --flake /mnt/etc/nixos#<host>
```

Reboot when it finishes.

## After First Boot

The installed system initially uses the hosts repo at `/etc/nixos`. To work from
a normal user clone instead, run the post-install migration from the private
hosts repo:

```sh
git clone <private-hosts-repo-url> ~/src/nixos-hosts
cd ~/src/nixos-hosts
make post-install-all
```

`post-install-all` is provided by the hosts template. It backs up `/etc/nixos`,
copies the generated hardware config into the clone, points `/etc/nixos` at the
clone, rebuilds, and enrolls TPM2 unlock for `/dev/disk/by-partlabel/cryptroot`.

Do not commit generated hardware config back to this public base. Commit it to
the private hosts repo.

## Add a Host in a Consumer Repo

1. Copy the public hosts template or an existing private host.
2. Add the host to the consumer repo's `flake.nix`.
3. Create `hosts/<new-host>/default.nix`.
4. Generate `hosts/<new-host>/hardware-configuration.nix`.
5. Rebuild:

   ```sh
   sudo nixos-rebuild switch --flake .#<new-host>
   ```

## Security

No secrets are intentionally stored here. Do not commit private keys, password
files, API tokens, or machine-specific secret material.

Local secret scanning uses `pre-commit` with `gitleaks`:

```sh
nix shell nixpkgs#pre-commit -c pre-commit install
nix shell nixpkgs#pre-commit -c pre-commit run --all-files
```

## License

MIT. See `LICENSE`.
