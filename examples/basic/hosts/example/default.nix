{
  hostname,
  username,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = hostname;
  time.timeZone = "Etc/UTC";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";
  services.xserver.xkb.layout = "us";
  system.stateVersion = "25.11";

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "audio"
      "networkmanager"
      "video"
      "wheel"
    ];
    shell = pkgs.zsh;
  };
}
