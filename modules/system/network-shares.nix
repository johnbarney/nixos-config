{ pkgs, ... }:
{
  services.gvfs.enable = true;
  services.rpcbind.enable = true;

  environment.systemPackages = with pkgs; [
    cifs-utils
    nfs-utils
    samba
  ];
}
