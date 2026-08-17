{ lib, ... }:
{
  networking.firewall.enable = lib.mkDefault true;
  networking.networkmanager.enable = true;
  networking.nftables.enable = true;

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    chrony.enable = true;
    firewalld.enable = true;
  };
}
