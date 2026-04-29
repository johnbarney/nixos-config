# NixOS Config (Dendritic)

Public base flake for reusable NixOS modules and installer support.
It is not a complete host configuration by itself.

Host definitions, generated hardware configs, Home Manager users, rebuild
commands, and ISO builds live in consumer repos. The public starter consumer is
[johnbarney/nixos-hosts-template](https://github.com/johnbarney/nixos-hosts-template).

## What This Exports

- `lib.moduleCatalog.hardware`: hardware modules such as CPU microcode, AMD/NVIDIA graphics, and TPM/LUKS support.
- `lib.moduleCatalog.systemSoftware`: system modules such as base OS settings, networking, network shares, audio, GNOME/KDE/Hyprland desktops, display managers, Flatpak, fonts, and wallpaper.
- `lib.moduleCatalog.userSoftware`: curated user-facing applications such as Chromium, Firefox, Steam, and 1Password.
- `lib.moduleCatalog.homeSoftware`: Home Manager modules such as default apps, SSH, Kitty, Breeze theming, GNOME/Plasma settings, and granular Hyprland user configuration.
- `lib.moduleCatalog.metaModules`: cross-menu module bundles such as `kde`, `gnome`, `hyprland`, and `onepassword`.
- `nixosModules.*`: flat aliases for the catalog modules, using names such as `hardware-cpu-amd`, `hardware-graphics-intel`, `hardware-graphics-nvidia`, `system-desktop-gnome-full`, `system-desktop-kde-full`, and `user-steam`.
- `homeModules.*`: flat aliases for Home Manager modules, using names such as `terminal-kitty` and `hyprland-full`.
- `nixosModules.installer`: live ISO customizations used by host repos.
- `lib.mkDendriticHost`: helper for building host configurations from explicit menus and optional metamodules.
- `lib.mergeMetaModules`: helper for combining metamodules into plain hardware/system/user/home software lists.

## Host Composition

Hosts can use metamodules for features that naturally span multiple menus:

```nix
dendritic.lib.mkDendriticHost {
  hostname = "example-kde";
  username = "alice";
  hostModule = ./hosts/example-kde;
  homeModule = ./home/alice/home.nix;

  metaModules = with dendritic.lib.moduleCatalog.metaModules; [
    kde
    onepassword
  ];

  hardware = with dendritic.lib.moduleCatalog.hardware; [
    cpuAmd
    graphicsNvidia
  ];

  systemSoftware = with dendritic.lib.moduleCatalog.systemSoftware; [
    base
    networking
    audioPipewire
    desktopServices
    displaySddm
    flatpak
    wallpaper
  ];

  userSoftware = with dendritic.lib.moduleCatalog.userSoftware; [
    steam
  ];

  homeSoftware = with dendritic.lib.moduleCatalog.homeSoftware; [
    base
    terminalKitty
  ];
}
```

Metamodules are only list bundles. They expand into the same hardware, system
software, user software, and home software menus used by explicit host
definitions. Desktop metamodules include the session, shared fonts, default
apps, and matching home theme pieces, so `kde` covers KDE, fonts, Chromium,
Konsole, Dolphin, GTK/Qt Breeze, and Plasma Breeze. Display managers stay
explicit in `systemSoftware` because a host should normally choose exactly one.
Ordinary package choices such as browsers, editors, and single-package apps
should live in host or home modules directly instead of being wrapped by this
catalog.

You can still build hosts from explicit lists when you want exact control:

```nix
dendritic.lib.mkDendriticHost {
  hostname = "example-desktop";
  username = "alice";
  hostModule = ./hosts/example-desktop;

  hardware = with dendritic.lib.moduleCatalog.hardware; [
    cpuAmd
    graphicsNvidia
  ];

  systemSoftware = with dendritic.lib.moduleCatalog.systemSoftware; [
    base
    networking
    audioPipewire
    desktopServices
    displaySddm
    desktopKdeFull
    flatpak
    fonts
    wallpaper
  ];

  userSoftware = with dendritic.lib.moduleCatalog.userSoftware; [
    onepassword
    steam
  ];

  homeSoftware = with dendritic.lib.moduleCatalog.homeSoftware; [
    base
    sshOnepasswordAgent
    terminalKitty
    gtkQtBreezeDark
    plasmaBreezeDark
    hyprlandFull
  ];

  homeModule = ./home/alice/home.nix;
}
```

## Installing Other Software

The catalog is curated. It is not meant to wrap every package in nixpkgs. For
ordinary software, install packages directly in the host or home module that
owns the choice.

System-wide host package example:

```nix
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    git
  ];
}
```

Per-user Home Manager package example:

```nix
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    git
  ];
}
```

Use the catalog when it provides a curated opinion, multiple related settings,
desktop defaults, or cross-layer wiring. Use `pkgs` directly for one-off apps
and tools.

## Generated Docs

Catalog documentation is generated from `lib/catalog-docs.nix` into `docs/`.
Those pages explain what each curated module does, when to use it, and what
each metamodule expands to.

```sh
make docs
```

Start with [docs/catalog.md](docs/catalog.md), then use the layer-specific
pages for details.

## Layout

- `flake.nix`: flake entrypoint.
- `flake/nixos-configurations.nix`: public flake API.
- `lib/catalog-docs.nix`: source data for generated catalog documentation.
- `docs/`: generated catalog documentation.
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
