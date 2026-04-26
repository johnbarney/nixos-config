# NixOS Config (Dendritic)

Public base flake for reusable NixOS modules, profiles, and installer support.
It is not a complete host configuration by itself.

Host definitions, generated hardware configs, Home Manager users, rebuild
commands, and ISO builds live in consumer repos. The public starter consumer is
[johnbarney/nixos-hosts-template](https://github.com/johnbarney/nixos-hosts-template).

## What This Exports

- `nixosModules.default` / `nixosModules.dendritic`: shared NixOS module set.
- `nixosModules.cpu-amd` / `nixosModules.cpu-intel`: optional CPU microcode modules.
- `nixosModules.desktop`: desktop profile without NVIDIA-specific settings.
- `nixosModules.desktop-nvidia`: desktop profile plus NVIDIA settings.
- `nixosModules.installer`: live ISO customizations used by host repos.
- `lib.mkDendriticHost`: helper for building host configurations from this base.

## Layout

- `flake.nix`: flake entrypoint.
- `flake/nixos-configurations.nix`: public flake API.
- `modules/nixos/`: shared NixOS modules.
- `profiles/`: composed machine profiles.
- `installer/`: reusable installer module and `install-nixos-host` helper.

## Repo Model

- This repo stays public and reusable.
- [`nixos-hosts-template`](https://github.com/johnbarney/nixos-hosts-template)
  shows how to consume this base without exposing real machine details.
- Private host repos fork or copy the template, commit real
  `hardware-configuration.nix` files, and update this base through their
  `dendritic` flake input.

## Commands

```sh
make help
make check
```

Consumers update this base with:

```sh
nix flake lock --update-input dendritic
```

## Security

No secrets are intentionally stored here. Do not commit private keys, password
files, API tokens, generated hardware configs, or machine-specific secret
material.

Local secret scanning uses `pre-commit` with `gitleaks`:

```sh
nix shell nixpkgs#pre-commit -c pre-commit install
nix shell nixpkgs#pre-commit -c pre-commit run --all-files
```

## License

MIT. See `LICENSE`.
