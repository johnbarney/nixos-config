# NixOS Config

Reusable, opinionated NixOS and Home Manager modules. This flake provides
standard `nixosModules` and `homeModules`; consumer repositories compose those
modules with `nixpkgs.lib.nixosSystem`.

The workstation browser is Brave Origin.

## Layers

- `modules/` contains focused hardware, system, application, and Home Manager
  capabilities.
- `profiles/system/` combines capabilities into workstation and desktop
  flavors.
- `profiles/home/` contains matching per-user desktop defaults.
- `installer/` provides configurable installer behavior shared by broad and
  host-specific images.
- `examples/basic/` is a complete, copyable host flake.

Machine identity, filesystems, boot configuration, time zone, users, and state
versions belong in the consumer host repository.

## Main Profiles

NixOS profiles:

- `nixosModules.workstation`
- `nixosModules.desktop-kde`
- `nixosModules.desktop-gnome`
- `nixosModules.desktop-hyprland`

Home Manager profiles:

- `homeModules.default`
- `homeModules.desktop-kde`
- `homeModules.desktop-gnome`
- `homeModules.desktop-hyprland`

Hardware, display-manager, Steam, 1Password, and installer modules are also
available under `nixosModules`. Run `nix flake show` for the complete public
surface.

The workstation profile includes AppImage and conventional dynamic-binary
compatibility, `nh` for day-to-day NixOS commands, and conservative weekly
store and disk maintenance. The Steam module adds GameMode, Protontricks,
Proton GE, Gamescope, and MangoHud.

## Broad Installer ISO

This repository owns the hardware-agnostic Plasma installer/recovery image. It
includes the broad firmware set and the reusable `install-nixos-host` helper,
but deliberately does not bundle a private hosts flake.

```sh
make build-iso
make iso-path
make iso-sha
```

Consumer repositories can import `nixosModules.installer`, disable the broad
firmware set, select their hardware modules, and bundle their own hosts flake.

## Start From the Example

Initialize a new consumer repository from the embedded example:

```sh
nix flake init -t github:johnbarney/nixos-config
nix flake lock
```

Then replace the example hardware configuration and identity values before
installing or switching a real machine. See
[`examples/basic/README.md`](examples/basic/README.md).

## Direct Composition

The example uses ordinary NixOS module composition:

```nix
modules = [
  nixos-config.nixosModules.workstation
  nixos-config.nixosModules.desktop-kde
  nixos-config.nixosModules.display-sddm
  ./hosts/example
];
```

Cross-layer choices remain explicit: select the NixOS profile in the system
module list and the matching Home Manager profile in the user's imports.

## Commands

```sh
make help
make check
make check-example
make build-iso
```

The weekly GitHub Actions workflow updates the lock file, evaluates the flake,
and opens or refreshes a reviewable pull request when inputs change.
GitHub repository settings must allow Actions to create pull requests.

## Security

Do not commit private keys, password files, API tokens, real private host data,
or other secret material. Local secret scanning uses `pre-commit` with
`gitleaks`.

## License

MIT. See `LICENSE`.
