{ lib, import-tree, ... }:
{
  imports = lib.remove ./default.nix ((import-tree.withLib lib).leafs ./.);
}
