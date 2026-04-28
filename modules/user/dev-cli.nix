{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    fd
    jq
    nil
    nixfmt
    ripgrep
    tree
  ];
}
