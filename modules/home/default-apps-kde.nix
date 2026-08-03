{ lib, ... }:
{
  imports = [
    ./default-apps.nix
  ];

  dendritic.defaultApps = {
    terminal = lib.mkDefault "konsole";
    fileManager = lib.mkDefault "dolphin";
  };
}
