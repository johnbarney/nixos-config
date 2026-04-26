{ lib, import-tree, ... }:
{
  imports =
    lib.remove ./nvidia.nix
      (lib.remove ./default.nix ((import-tree.withLib lib).leafs ./.));
}
