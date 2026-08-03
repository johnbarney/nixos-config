{ pkgs, ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";
  services.xserver.xkb.layout = "us";

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    curl
    git
    gnumake
    vim
  ];
}
