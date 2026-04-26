{ lib, import-tree, ... }:
let
  excluded = [
    ./cpu-amd.nix
    ./cpu-intel.nix
    ./default.nix
    ./nvidia.nix
  ];
in
{
  imports = lib.subtractLists excluded ((import-tree.withLib lib).leafs ./.);
}
