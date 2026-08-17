{ lib, ... }:
{
  # Make the firmware normally expected by workstation hardware available while
  # still allowing a consumer to enforce a free-firmware-only policy.
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Keep diagnostics across boots. NixOS already uses conservative journald
  # size limits, so no additional fixed cap is imposed here.
  services.journald.storage = lib.mkDefault "persistent";

  # Follow Fedora's workstation policy: compressed RAM swap absorbs short
  # memory spikes, and oomd acts before the kernel's last-resort OOM killer.
  systemd.oomd = {
    enable = lib.mkDefault true;
    enableRootSlice = lib.mkDefault true;
    enableUserSlices = lib.mkDefault true;
  };

  zramSwap.enable = lib.mkDefault true;
}
