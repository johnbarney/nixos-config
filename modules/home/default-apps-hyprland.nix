{ lib, ... }:
{
  imports = [
    ./default-apps.nix
  ];

  dendritic.defaultApps = {
    browser = lib.mkDefault "chromium";
    terminal = lib.mkDefault "kitty";
    fileManager = lib.mkDefault "dolphin";
  };
}
