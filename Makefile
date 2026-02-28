SHELL := /usr/bin/env bash

HOST ?= taipei-linux
ISO_PACKAGE ?= taipei-installer-iso
ISO_GLOB ?= ./result/iso/*.iso

.PHONY: help check build-iso iso-path iso-sha switch test-switch update-lock update-lock-nixpkgs update-lock-home-manager update-lock-plasma-manager

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
