# NixOS Config (Dendritic)

Public NixOS base flake for reusable desktop modules, profiles, installer
machinery, and reference host wiring. Real machine-specific host state should
live in a private consumer flake.

## Hosts

| Host | Profile | Notes |
| --- | --- | --- |
| `example-desktop` | `profiles/desktop-nvidia.nix` | Sanitized reference host |

Host metadata lives in `hosts/default.nix`. Per-host hardware config lives under
`hosts/<host>/hardware-configuration.nix`.

The committed hardware files in this public repo are placeholders. Generated
hardware configs belong in a private host repo or private fork, not in public
history.

## Layout

- `flake.nix` delegates the flake body to `flake/` through `flake-parts`.
- `flake/nixos-configurations.nix` defines host outputs and the installer ISO package.
- `hosts/` contains sanitized example host configuration.
- `profiles/` composes reusable machine profiles.
- `modules/nixos/` contains shared NixOS modules, including desktop, NVIDIA, TPM unlock, and service configuration.
- `home/alice/` contains sanitized example Home Manager configuration.
- `installer/` customizes the live ISO and provides `install-nixos-host`.
- `templates/private-hosts/` is a starter private-host flake that consumes this
  repo as a public base.

## Repo Model

This repo is the public base. It should stay reusable and educational, while
machine-specific state lives elsewhere.

Recommended repo split:

- `nixos-config`: public base with reusable modules, profiles, installer code,
  and sanitized examples.
- `nixos-hosts-template`: public starter repo that shows how to consume this
  base without exposing real machine details.
- A private hosts repo: personal machine definitions, generated hardware
  configs, and private host choices.

This base exposes:

- `nixosModules.default` / `nixosModules.dendritic` for the shared NixOS modules.
- `nixosModules.desktop-nvidia` for the current desktop profile.
- `lib.mkDendriticHost` for private or template flakes to build hosts from this base.
- `templates.hosts` as a starting point for a public template or private hosts
  repo.

Create a consumer from the template:

```sh
nix flake init -t github:johnbarney/nixos-config#hosts
```

A public template repo should keep sanitized placeholder hardware configs. A
private hosts repo should commit real `hardware-configuration.nix` files and any
private host identity. Either kind of consumer can update this public base with:

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
make build-iso
```

The ISO build is copied to `./result/iso/*.iso`; `make build-iso` also prints
its SHA256. Use `make iso-path` or `make iso-sha` to inspect an existing build.

Host rebuilds should usually happen from a consumer repo. This public base only
contains the sanitized `example-desktop` host.

## Install From This Repo's ISO

1. Build and boot the installer:

   ```sh
   make build-iso
   ```

2. Partition and mount the target system under `/mnt`.

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

3. Confirm the mount tree:

   ```sh
   findmnt /mnt
   ```

4. Start `Install NixOS Host (Flake)` from the live desktop menu, or run:

   ```sh
   sudo install-nixos-host
   ```

   To skip the host picker:

   ```sh
   sudo install-nixos-host example-desktop
   ```

The installer copies the ISO's embedded repo from `/etc/nixos-config` to
`/mnt/etc/nixos`, regenerates `hosts/<host>/hardware-configuration.nix`, and
runs:

```sh
nixos-install --root /mnt --flake /mnt/etc/nixos#<host>
```

Reboot when it finishes.

For a private consumer repo, use the same partitioning and mount flow, then run
`nixos-install --root /mnt --flake .#<host>` from that private flake once its
generated hardware config is in place.

## After First Boot

The installed system initially uses the repo copy at `/etc/nixos`. For a real
machine, move to a private hosts repo after first boot:

```sh
git clone <private-hosts-repo-url> ~/src/nixos-hosts
cd ~/src/nixos-hosts
make post-install-all
```

`post-install-all` backs up `/etc/nixos`, copies the generated hardware config
into the clone, points `/etc/nixos` at the clone, rebuilds, and enrolls TPM2
unlock for `/dev/disk/by-partlabel/cryptroot`.

Do not commit generated hardware config back to this public base. Commit it to
the private hosts repo.

Run the same steps manually if you need to inspect each stage:

```sh
make post-install-backup
make post-install-copy-hw
make post-install-link
make post-install-switch
make post-install-cryptenroll
```

Override the inferred host or cryptroot device when needed:

```sh
make post-install-all HOST=<host>
make post-install-cryptenroll CRYPTROOT_DEVICE=/dev/disk/by-uuid/<uuid>
```

## Add a Host in a Consumer Repo

1. Copy the public hosts template or an existing private host.
2. Add the host to the consumer repo's `flake.nix`.
3. Create `hosts/<new-host>/default.nix`.
4. Generate `hosts/<new-host>/hardware-configuration.nix`.
5. Rebuild:

   ```sh
   sudo nixos-rebuild switch --flake .#<new-host>
   ```

For this public base's local example:

1. Add the host to `hosts/default.nix`.
2. Create `hosts/<new-host>/default.nix`.
3. Add a placeholder `hosts/<new-host>/hardware-configuration.nix`, or install
   from the ISO and let `install-nixos-host` generate it.
4. Rebuild:

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
