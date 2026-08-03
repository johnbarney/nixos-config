{ lib, ... }:
{
  imports = [
    ./default-apps.nix
  ];

  dendritic.defaultApps = {
    terminal = lib.mkDefault "gnomeConsole";
    fileManager = lib.mkDefault "nautilus";
  };
}
