# Example NixOS Hosts

This is a copyable consumer of `github:johnbarney/nixos-config`. It uses native
NixOS and Home Manager module composition. The flake exposes one example node
for each desktop flavor:

- `fedora-kde`: workstation + Fedora KDE + SDDM
- `fedora-gnome`: workstation + Fedora GNOME + GDM
- `omarchy`: workstation + Omarchy (Hyprland and Quickshell) + SDDM

`make test-switch` uses `fedora-kde` by default. Select another example with,
for example, `make test-switch HOST=omarchy`.

The example nodes omit optional capabilities. Add
`nixos-config.nixosModules.gaming` to any node that should include Steam and the
gaming tools; it is independent of the selected desktop and graphics module.

Before using it on a real machine:

1. Keep the desired `mkHost` call, give it the real hostname, and rename
   `alice` and the corresponding home path if needed.
2. Replace `hosts/example/hardware-configuration.nix` with the generated file
   from the target machine.
3. Review the generated filesystems and bootloader against the intended disk
   layout. For an encrypted SSD, decide whether its LUKS mapping should allow
   discards; they are needed for TRIM to pass through dm-crypt but reveal block
   allocation patterns.
4. Review the time zone and both state-version values. State versions record
   the initial installation version; do not bump them during routine upgrades.
5. Run `nix flake lock` followed by `make check`.
6. Use `make test-switch` before `make switch` on an existing system.

The placeholder disk configuration exists only to keep this example evaluable.
Do not install it unchanged.
