{ pkgs, lib, self, ... }:
let
  installScript = pkgs.writeShellScriptBin "install-taipei-linux" ''
    set -euo pipefail

    target_root="/mnt"
    repo_src="/etc/nixos-config"
    repo_dst="''${target_root}/etc/nixos"
    host="taipei-linux"

    if [[ ! -d "$target_root" ]]; then
      echo "Missing target root: $target_root"
      exit 1
    fi

    echo "Preparing target repo at $repo_dst ..."
    mkdir -p "$repo_dst"
    cp -a "$repo_src"/. "$repo_dst"/

    echo "Generating hardware config for $host ..."
    mkdir -p "$repo_dst/hosts/$host"
    nixos-generate-config --show-hardware-config --root "$target_root" > "$repo_dst/hosts/$host/hardware-configuration.nix"

    echo
    echo "Running nixos-install with flake target $host ..."
    nixos-install --root "$target_root" --flake "$repo_dst#$host"

    echo
    echo "Install finished. If TPM unlock is desired, enroll TPM after first boot:"
    echo "  sudo systemd-cryptenroll --tpm2-device=auto /dev/disk/by-uuid/<LUKS-UUID>"
  '';

  installDesktopEntry = pkgs.makeDesktopItem {
    name = "install-taipei-linux";
    desktopName = "Install Taipei Linux (Flake)";
    comment = "Apply the repo flake to /mnt and install taipei-linux";
    categories = [ "System" ];
    terminal = true;
    exec = "pkexec ${installScript}/bin/install-taipei-linux";
    icon = "nix-snowflake";
  };
in
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # Improve hardware compatibility in the live ISO (notably Wi-Fi chipsets).
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  environment.etc."nixos-config".source = self;

  environment.systemPackages = with pkgs; [
    git
    installScript
    installDesktopEntry
  ];

  # Ensure the desktop launcher appears in the live session menu.
  environment.pathsToLink = [ "/share/applications" ];

  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  isoImage.volumeID = lib.mkForce "NIXOSTAIPEI2511";
  isoImage.edition = lib.mkForce "plasma6taipei";
}
