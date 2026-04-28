{ ... }:
{
  networking.networkmanager.enable = true;
  networking.nftables.enable = true;
  services.firewalld.enable = true;
  services.chrony.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
