# NixOS Config

Reusable, opinionated NixOS and Home Manager modules. This flake provides
standard `nixosModules` and `homeModules`; consumer repositories compose those
modules with `nixpkgs.lib.nixosSystem`.

## Layers

- `modules/` contains focused hardware, system, application, and Home Manager
  capabilities.
- `profiles/system/` combines capabilities into workstation and desktop
  flavors.
- `profiles/home/` contains matching per-user desktop defaults.
- `installer/` provides the reusable installer ISO customization.
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

Hardware, display-manager, Steam, 1Password, installer, and granular module
exports are also available under `nixosModules`. Run `nix flake show` for the
complete public surface.

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
