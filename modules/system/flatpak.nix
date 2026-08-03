{ pkgs, ... }:
{
  services.flatpak.enable = true;

  systemd.services.flatpak-flathub = {
    description = "Add Flathub remote";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists --system flathub https://flathub.org/repo/flathub.flatpakrepo";
    };
  };
}
