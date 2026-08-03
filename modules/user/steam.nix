{ pkgs, ... }:
{
  imports = [ ../system/unfree.nix ];

  programs.gamemode.enable = true;

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    protontricks.enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  environment.systemPackages = [ pkgs.mangohud ];
}
