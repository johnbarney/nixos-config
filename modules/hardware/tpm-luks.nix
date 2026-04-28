{ ... }:
{
  # Enable TPM2 for LUKS unlock
  security.tpm2.enable = true;

  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.tpm2.enable = true;
  boot.initrd.luks.devices = {
    cryptroot = {
      device = "/dev/disk/by-partlabel/cryptroot";
      preLVM = true;
      crypttabExtraOpts = [ "tpm2-device=auto" "tpm2-pcrs=7" ];
    };
  };
}
