{ lib, ... }:
{
  imports = [
    ./default-apps.nix
  ];

  dendritic.defaultApps = {
    browser = lib.mkDefault "firefox";
    terminal = lib.mkDefault "gnomeConsole";
    fileManager = lib.mkDefault "nautilus";
  };
}
