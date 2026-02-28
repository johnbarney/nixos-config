{ ... }:
{
  # Enable TPM2 for LUKS unlock
  security.tpm2.enable = true;

  boot.initrd.systemd.enable = true;
  boot.initrd.luks.devices = {
    cryptroot = {
      device = "/dev/disk/by-uuid/REPLACE-WITH-LUKS-UUID";
      preLVM = true;
      tpm2 = {
        enable = true;
        pcrs = [ 7 ];
      };
    };
  };
}
