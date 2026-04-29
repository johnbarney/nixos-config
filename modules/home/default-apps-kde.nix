{ lib, ... }:
{
  imports = [
    ./default-apps.nix
  ];

  dendritic.defaultApps = {
    browser = lib.mkDefault "chromium";
    terminal = lib.mkDefault "konsole";
    fileManager = lib.mkDefault "dolphin";
  };
}
