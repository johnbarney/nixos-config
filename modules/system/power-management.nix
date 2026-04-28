{ pkgs, ... }:
{
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.logind.settings.Login.HandlePowerKey = "ignore";

  systemd.services.power-profile-performance = {
    description = "Set power profile to performance";
    wantedBy = [ "multi-user.target" ];
    after = [ "power-profiles-daemon.service" ];
    wants = [ "power-profiles-daemon.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance";
    };
  };
}
