SHELL := /usr/bin/env bash

HOST ?= taipei-linux
ISO_PACKAGE ?= taipei-installer-iso
ISO_GLOB ?= ./result/iso/*.iso
ETC_NIXOS ?= /etc/nixos
BACKUP_DIR ?= /etc/nixos.bak
CRYPTROOT_DEVICE ?= /dev/disk/by-partlabel/cryptroot
REPO_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

.PHONY: help check build-iso iso-path iso-sha switch test-switch update-lock update-lock-nixpkgs update-lock-home-manager update-lock-plasma-manager post-install-backup post-install-copy-hw post-install-link post-install-switch post-install-cryptenroll post-install-all

help: ## Show available targets
	@grep -E '^[a-zA-Z0-9._-]+:.*## ' $(MAKEFILE_LIST) | sed 's/:.*## /: /' | sort

check: ## Run flake checks (no build)
	nix flake check --no-build

build-iso: ## Build installer ISO
	nix build .#$(ISO_PACKAGE) -L

iso-path: ## Print built ISO path(s)
	@ls -1 $(ISO_GLOB)

iso-sha: ## Print SHA256 for built ISO(s)
	sha256sum $(ISO_GLOB)

switch: ## Rebuild and switch current system for HOST (uses sudo)
	sudo nixos-rebuild switch --flake .#$(HOST)

test-switch: ## Build and test switch for HOST (uses sudo)
	sudo nixos-rebuild test --flake .#$(HOST)

update-lock: ## Update all flake inputs
	nix flake update

update-lock-nixpkgs: ## Update nixpkgs lock input only
	nix flake lock --update-input nixpkgs

update-lock-home-manager: ## Update home-manager lock input only
	nix flake lock --update-input home-manager

update-lock-plasma-manager: ## Update plasma-manager lock input only
	nix flake lock --update-input plasma-manager

post-install-backup: ## Backup /etc/nixos to /etc/nixos.bak (uses sudo)
	sudo mv $(ETC_NIXOS) $(BACKUP_DIR)

post-install-copy-hw: ## Copy generated hardware config from backup into current repo
	mkdir -p "$(REPO_DIR)/hosts/$(HOST)"
	cp "$(BACKUP_DIR)/hosts/$(HOST)/hardware-configuration.nix" "$(REPO_DIR)/hosts/$(HOST)/hardware-configuration.nix"

post-install-link: ## Symlink /etc/nixos to current repo (uses sudo)
	sudo ln -sfn "$(REPO_DIR)" "$(ETC_NIXOS)"

post-install-switch: ## Rebuild and switch from /etc/nixos for HOST (uses sudo)
	sudo nixos-rebuild switch --flake "$(ETC_NIXOS)#$(HOST)"

post-install-cryptenroll: ## Enroll TPM2 unlock for cryptroot (uses sudo)
	sudo systemd-cryptenroll --tpm2-device=auto "$(CRYPTROOT_DEVICE)"

post-install-all: post-install-backup post-install-copy-hw post-install-link post-install-switch post-install-cryptenroll ## Run full post-install migration flow
