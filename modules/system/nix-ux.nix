{ lib, ... }:
{
  programs.nh = {
    enable = true;
    flake = lib.mkDefault "/etc/nixos";

    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep 5 --keep-since 30d";
    };
  };
}
