# NixOS Config (Dendritic)

Public base flake for reusable NixOS modules and installer support.
It is not a complete host configuration by itself.

Host definitions, generated hardware configs, Home Manager users, rebuild
commands, and ISO builds live in consumer repos. The public starter consumer is
[johnbarney/nixos-hosts-template](https://github.com/johnbarney/nixos-hosts-template).

## What This Exports

- `lib.moduleCatalog.hardware`: hardware modules such as CPU microcode, AMD graphics, NVIDIA, and TPM/LUKS support.
- `lib.moduleCatalog.systemSoftware`: system modules such as base OS settings, networking, audio, desktop environments, display managers, Flatpak, fonts, and wallpaper.
- `lib.moduleCatalog.userSoftware`: user-facing software modules such as Chromium, Heroic, Steam, VS Code, and 1Password.
- `nixosModules.*`: flat aliases for the catalog modules, using names such as `hardware-cpu-amd`, `hardware-graphics-amd`, `system-desktop-kde-full`, and `user-steam`.
- `nixosModules.installer`: live ISO customizations used by host repos.
- `lib.mkDendriticHost`: helper for building host configurations from hardware, system software, and user software lists.

## Host Composition

Hosts are built from three explicit lists:

```nix
dendritic.lib.mkDendriticHost {
  hostname = "example-desktop";
  username = "alice";
  hostModule = ./hosts/example-desktop;

  hardware = with dendritic.lib.moduleCatalog.hardware; [
    cpuAmd
    nvidia
  ];

  systemSoftware = with dendritic.lib.moduleCatalog.systemSoftware; [
    base
    networking
    audioPipewire
    desktopServices
    desktopKdeFull
    displaySddm
    flatpak
    fonts
    wallpaper
  ];

  userSoftware = with dendritic.lib.moduleCatalog.userSoftware; [
    chromium
    heroic
    onepassword
    steam
    vscode
  ];
}
```

## Layout

- `flake.nix`: flake entrypoint.
- `flake/nixos-configurations.nix`: public flake API.
- `modules/hardware/`: hardware, firmware, GPU, CPU, and platform support.
- `modules/system/`: operating system services and desktop/session support.
- `modules/user/`: user-facing software.
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
nix flake update dendritic
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
