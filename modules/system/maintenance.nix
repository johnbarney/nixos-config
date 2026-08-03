{ ... }:
{
  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };

  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  services.smartd = {
    enable = true;
    autodetect = true;
  };
}
