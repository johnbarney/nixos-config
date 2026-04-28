{ ... }:
{
  imports = [
    ./avahi.nix
    ./firewall.nix
    ./networkmanager.nix
    ./time-sync.nix
  ];
}
