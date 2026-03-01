{ pkgs, lib, self, ... }:
let
  installScript = pkgs.writeShellScriptBin "install-nixos-host" ''
    set -euo pipefail

    target_root="/mnt"
    repo_src="/etc/nixos-config"
    repo_dst="''${target_root}/etc/nixos"
    host_arg="''${1:-}"

    list_hosts() {
      find "$repo_src/hosts" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' \
        | while IFS= read -r candidate; do
            if [[ -f "$repo_src/hosts/$candidate/default.nix" ]]; then
              printf '%s\n' "$candidate"
            fi
          done \
        | sort
    }

    if [[ ! -d "$target_root" ]]; then
      echo "Missing target root: $target_root"
      exit 1
    fi

    if [[ ! -d "$repo_src/hosts" ]]; then
      echo "Missing hosts directory: $repo_src/hosts"
      exit 1
    fi

    mapfile -t available_hosts < <(list_hosts)
    if [[ "''${#available_hosts[@]}" -eq 0 ]]; then
      echo "No installable hosts found in $repo_src/hosts"
      exit 1
    fi

    host="$host_arg"
    if [[ -z "$host" ]]; then
      echo "Available hosts:"
      for i in "''${!available_hosts[@]}"; do
        printf '  %d) %s\n' "$((i + 1))" "''${available_hosts[$i]}"
      done
      echo
      read -r -p "Select host number: " host_idx
      if [[ ! "$host_idx" =~ ^[0-9]+$ ]] || (( host_idx < 1 || host_idx > ''${#available_hosts[@]} )); then
        echo "Invalid selection: $host_idx"
        exit 1
      fi
      host="''${available_hosts[$((host_idx - 1))]}"
    fi

    if ! printf '%s\n' "''${available_hosts[@]}" | grep -Fxq "$host"; then
      echo "Unknown host: $host"
      echo "Available hosts: ''${available_hosts[*]}"
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

  installTaipeiCompatScript = pkgs.writeShellScriptBin "install-taipei-linux" ''
    exec ${installScript}/bin/install-nixos-host taipei-linux
  '';

  installDesktopEntry = pkgs.makeDesktopItem {
    name = "install-nixos-host";
    desktopName = "Install NixOS Host (Flake)";
    comment = "Choose a host from this repo and install it to /mnt";
    categories = [ "System" ];
    terminal = true;
    exec = "pkexec ${installScript}/bin/install-nixos-host";
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
    installTaipeiCompatScript
    installDesktopEntry
  ];

  # Ensure the desktop launcher appears in the live session menu.
  environment.pathsToLink = [ "/share/applications" ];

  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  isoImage.volumeID = lib.mkForce "NIXOSTAIPEI2511";
  isoImage.edition = lib.mkForce "plasma6taipei";
}
