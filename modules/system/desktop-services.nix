{ ... }:
{
  imports = [ ./network-shares.nix ];

  hardware.bluetooth.enable = true;
  programs.dconf.enable = true;

  services = {
    fwupd.enable = true;
    printing.enable = true;
    power-profiles-daemon.enable = true;
    udisks2.enable = true;
    upower.enable = true;
  };
}
