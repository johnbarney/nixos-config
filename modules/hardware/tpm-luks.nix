{ lib, ... }:
{
  # Enable TPM2 for LUKS unlock
  security.tpm2.enable = true;

  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.tpm2.enable = true;
  boot.initrd.luks.devices = {
    cryptroot = {
      device = "/dev/disk/by-partlabel/cryptroot";
      # Discards reveal which encrypted blocks are allocated. Keep them off by
      # default; SSD hosts can explicitly opt in after accepting that tradeoff.
      allowDiscards = lib.mkDefault false;
      crypttabExtraOpts = [ "tpm2-device=auto" "tpm2-pcrs=7" ];
    };
  };
}
