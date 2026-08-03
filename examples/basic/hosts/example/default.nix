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
