{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.nixosConfig.installer;
  bundledHostsFlake = if cfg.hostsFlake == null then "" else toString cfg.hostsFlake;

  installScript = pkgs.writeShellScriptBin "install-nixos-host" ''
    set -euo pipefail

    target_root="/mnt"
    repo_dst="''${target_root}/etc/nixos"
    host_arg="''${1:-}"
    default_repo_src=${lib.escapeShellArg bundledHostsFlake}
    repo_src="''${2:-$default_repo_src}"

    list_hosts() {
      find "$repo_dst/hosts" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' \
        | while IFS= read -r candidate; do
            if [[ -f "$repo_dst/hosts/$candidate/default.nix" ]]; then
              printf '%s\n' "$candidate"
            fi
          done \
        | sort
    }

    if [[ ! -d "$target_root" ]]; then
      echo "Missing target root: $target_root"
      exit 1
    fi

    if [[ -n "$repo_src" ]]; then
      if [[ ! -d "$repo_src" ]]; then
        echo "Missing source host repo: $repo_src"
        exit 1
      fi

      echo "Copying host repo from $repo_src to $repo_dst ..."
      mkdir -p "$repo_dst"
      cp -a "$repo_src"/. "$repo_dst"/
    fi

    if [[ ! -d "$repo_dst/hosts" ]]; then
      echo "Missing host repo at $repo_dst"
      echo "Clone or copy a hosts flake there first, or pass a local source repo:"
      echo "  sudo install-nixos-host <host> /path/to/hosts-repo"
      exit 1
    fi

    mapfile -t available_hosts < <(list_hosts)
    if [[ "''${#available_hosts[@]}" -eq 0 ]]; then
      echo "No installable hosts found in $repo_dst/hosts"
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
    name = "install-nixos-host";
    desktopName = "Install NixOS Host (Flake)";
    comment =
      if cfg.hostsFlake == null then
        "Choose a host from /mnt/etc/nixos and install it to /mnt"
      else
        "Copy the bundled hosts flake, choose a host, and install it to /mnt";
    categories = [ "System" ];
    terminal = true;
    exec = "pkexec ${installScript}/bin/install-nixos-host";
    icon = "nix-snowflake";
  };
in
{
  imports = [
    ../modules/system/base.nix
    ../modules/system/unfree.nix
  ];

  options.nixosConfig.installer = {
    hostsFlake = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Optional hosts flake copied to /mnt/etc/nixos by the installer launcher.";
    };

    enableAllFirmware = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include non-redistributable firmware for a broad recovery image.";
    };

    volumeId = lib.mkOption {
      type = lib.types.str;
      default = "NIXOSINSTALLER";
      description = "ISO volume identifier.";
    };

    edition = lib.mkOption {
      type = lib.types.str;
      default = "plasma6installer";
      description = "Short installer edition name used in the ISO filename.";
    };
  };

  config = {
    # The public image defaults to maximum compatibility. Consumer images can
    # disable the non-redistributable set when their hardware is known.
    hardware.enableRedistributableFirmware = true;
    hardware.enableAllFirmware = cfg.enableAllFirmware;

    environment.systemPackages = with pkgs; [
      git
      installScript
      installDesktopEntry
    ];

    # Ensure the desktop launcher appears in the live session menu.
    environment.pathsToLink = [ "/share/applications" ];

    isoImage.makeEfiBootable = true;
    isoImage.makeUsbBootable = true;
    isoImage.volumeID = lib.mkForce cfg.volumeId;
    isoImage.edition = lib.mkForce cfg.edition;
  };
}
