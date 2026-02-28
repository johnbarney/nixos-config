SHELL := /usr/bin/env bash

HOST ?= taipei-linux
ISO_PACKAGE ?= taipei-installer-iso
ISO_GLOB ?= ./result/iso/*.iso
REPO_URL ?=
SRC_DIR ?= $(HOME)/src/nixos-config
ETC_NIXOS ?= /etc/nixos
BACKUP_DIR ?= /etc/nixos.bak

.PHONY: help check build-iso iso-path iso-sha switch test-switch update-lock update-lock-nixpkgs update-lock-home-manager update-lock-plasma-manager post-install-backup post-install-clone post-install-copy-hw post-install-link post-install-switch post-install-all

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

post-install-clone: ## Clone this repo to SRC_DIR (requires REPO_URL=...)
	@test -n "$(REPO_URL)" || (echo "Set REPO_URL, e.g. make $@ REPO_URL=git@github.com:you/repo.git" >&2; exit 1)
	mkdir -p "$(dir $(SRC_DIR))"
	git clone "$(REPO_URL)" "$(SRC_DIR)"

post-install-copy-hw: ## Copy generated hardware config from backup into cloned repo
	cp "$(BACKUP_DIR)/hosts/$(HOST)/hardware-configuration.nix" "$(SRC_DIR)/hosts/$(HOST)/hardware-configuration.nix"

post-install-link: ## Symlink /etc/nixos to cloned repo (uses sudo)
	sudo ln -sfn "$(SRC_DIR)" "$(ETC_NIXOS)"

post-install-switch: ## Rebuild and switch from /etc/nixos for HOST (uses sudo)
	sudo nixos-rebuild switch --flake "$(ETC_NIXOS)#$(HOST)"

post-install-all: post-install-backup post-install-clone post-install-copy-hw post-install-link post-install-switch ## Run full post-install migration flow
