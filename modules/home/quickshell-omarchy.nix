{ ... }:
{
  programs.quickshell = {
    enable = true;
    configs.omarchy = ../../quickshell/omarchy;
    activeConfig = "omarchy";
    systemd = {
      enable = true;
      target = "graphical-session.target";
    };
  };

  services.hyprpolkitagent.enable = true;

  # UWSM owns graphical-session.target. Stop the shell with the session instead
  # of leaving it alive across compositor restarts.
  systemd.user.services.quickshell.Unit.PartOf = [ "graphical-session.target" ];
}
