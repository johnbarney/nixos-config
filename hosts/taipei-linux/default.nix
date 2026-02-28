{ hostname, username, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
  ];

  # Fallbacks for repo evaluation before real hardware config is generated.
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  boot.loader.grub.devices = lib.mkDefault [ "/dev/sda" ];

  networking.hostName = hostname;

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "lp" "scanner" "plugdev" ];
    shell = pkgs.zsh;
  };
}
