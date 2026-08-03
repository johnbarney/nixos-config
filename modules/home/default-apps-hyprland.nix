{ lib, ... }:
{
  imports = [
    ./default-apps.nix
  ];

  dendritic.defaultApps = {
    terminal = lib.mkDefault "kitty";
    fileManager = lib.mkDefault "dolphin";
  };
}
