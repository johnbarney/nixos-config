{ pkgs, ... }:
{
  programs.home-manager.enable = true;
  programs.zsh.enable = true;

  home.packages = with pkgs; [
    curl
    git
    gnumake
    vim
  ];
}
