{ lib, ... }:
{
  # Evaluation-only placeholders. Replace this file with the output of
  # `nixos-generate-config --show-hardware-config` before using a real host.
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  boot.loader.grub.devices = lib.mkDefault [ "/dev/sda" ];
}
