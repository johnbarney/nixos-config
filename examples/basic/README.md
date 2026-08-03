# Example NixOS Host

This is a copyable consumer of `github:johnbarney/nixos-config`. It uses native
NixOS and Home Manager module composition without a custom host factory.

Before using it on a real machine:

1. Rename `example` and `alice` in `flake.nix` and the corresponding paths.
2. Replace `hosts/example/hardware-configuration.nix` with the generated file
   from the target machine.
3. Review the time zone and both state-version values. State versions record
   the initial installation version; do not bump them during routine upgrades.
4. Run `nix flake lock` followed by `make check`.
5. Use `make test-switch` before `make switch` on an existing system.

The placeholder disk configuration exists only to keep this example evaluable.
Do not install it unchanged.
