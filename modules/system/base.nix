{ pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Asia/Ho_Chi_Minh";
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

  system.stateVersion = "25.11";
}
