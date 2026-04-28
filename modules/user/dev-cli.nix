{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    fd
    jq
    nil
    nixfmt-rfc-style
    ripgrep
    tree
  ];
}
