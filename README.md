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

System composition has independent axes for machine role, desktop experience,
hardware, and optional capabilities. `workstation` is the current machine-role
profile; a future `laptop` peer can add power-saving and battery-oriented
defaults without coupling them to a particular desktop or capability.

Machine-role profiles:

- `nixosModules.workstation`

Desktop-experience profiles:

- `nixosModules.desktop-fedora-kde`: Plasma with Fedora-like desktop defaults
- `nixosModules.desktop-fedora-gnome`: GNOME with Fedora-like desktop defaults
- `nixosModules.desktop-omarchy`: Hyprland with an Omarchy-inspired Quickshell

Home Manager profiles:

- `homeModules.default`
- `homeModules.desktop-fedora-kde`
- `homeModules.desktop-fedora-gnome`
- `homeModules.desktop-omarchy`

Optional capability profiles:

- `nixosModules.gaming`: Steam, GameMode, Gamescope, Protontricks, Proton GE,
  and MangoHud

`gaming` is independent of machine role, desktop flavor, and GPU vendor. Add it
to any composition only when that host should include the gaming stack; it does
not imply `workstation` or `hardware-graphics-nvidia`, and neither of those
profiles implies `gaming`.

Hardware, display-manager, 1Password, and installer modules are also available
under `nixosModules`. Run `nix flake show` for the complete public surface.

The workstation profile includes AppImage and conventional dynamic-binary
compatibility, `nh` for day-to-day NixOS commands, and conservative weekly
store and disk maintenance. The gaming profile adds GameMode, Protontricks,
Proton GE, Gamescope, and MangoHud.

## OS Baseline

The `workstation` role provides a hardware-agnostic operating-system baseline:

- redistributable device firmware, with CPU microcode supplied by the selected
  AMD or Intel CPU module
- NetworkManager, a default-deny firewalld/nftables firewall, and Chrony time
  synchronization
- persistent systemd journal data, firmware updates through fwupd, and SMART
  disk monitoring
- weekly filesystem TRIM, Nix-store optimization, and conservative `nh`
  generation cleanup
- zram swap and systemd-oomd pressure handling for the root and user slices, in
  line with Fedora workstation behavior

Bootloader choice, partitioning, filesystem layout and mount options, Secure
Boot, encryption enrollment, and disk-backed swap or hibernation remain host
responsibilities because they depend on the machine and installation layout.
The consumer must also select the correct CPU and graphics modules.

Weekly `fstrim` covers filesystems whose block-device stack accepts discard
requests. LUKS intentionally blocks discards by default because they expose
encrypted-block allocation patterns. An encrypted SSD using
`nixosModules.hardware-tpm-luks` can opt in after accepting that tradeoff:

```nix
boot.initrd.luks.devices.cryptroot.allowDiscards = true;
```

The setting and device name must match the host's actual LUKS layout. See the
[NixOS LUKS option](https://nixos.org/manual/nixos/unstable/options#opt-boot.initrd.luks.devices._name_.allowDiscards)
and systemd's [`crypttab` documentation](https://www.freedesktop.org/software/systemd/man/250/crypttab.html#discard)
for the security warning.

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
  nixos-config.nixosModules.desktop-fedora-kde
  nixos-config.nixosModules.display-sddm
  nixos-config.nixosModules.hardware-graphics-amd
  nixos-config.nixosModules.gaming # Optional; works with AMD, Intel, or NVIDIA.
  ./hosts/example
];
```

Cross-layer choices remain explicit: select the NixOS profile in the system
module list and the matching Home Manager profile in the user's imports.

The example flake includes `fedora-kde`, `fedora-gnome`, and `omarchy` nodes so
each complete system/home/display-manager composition can be evaluated and
copied independently.

## Omarchy Inspiration and Attribution

The `desktop-omarchy` profile is an unofficial NixOS adaptation inspired by
[Omarchy](https://github.com/basecamp/omarchy). It is not affiliated with or
endorsed by Basecamp or David Heinemeier Hansson.

The profile adapts Omarchy's Hyprland interaction conventions, one-process
Quickshell architecture, bar composition, and Catppuccin palette to native
NixOS and Home Manager modules. The implementation in
[`quickshell/omarchy/`](quickshell/omarchy/) is original to this repository and
does not copy Omarchy's Quickshell source. It intentionally provides a smaller
foundation rather than reproducing Omarchy's Arch Linux installer, command
suite, or plugin system. See Omarchy's
[shell architecture documentation](https://github.com/basecamp/omarchy/blob/quattro/docs/omarchy-shell.md)
and [theming documentation](https://github.com/basecamp/omarchy/blob/quattro/docs/theming.md)
for the upstream designs that informed this profile.

Omarchy is distributed under the
[MIT License](https://github.com/basecamp/omarchy/blob/quattro/LICENSE),
Copyright (c) David Heinemeier Hansson. Omarchy remains the work of its
copyright holders and contributors.

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
