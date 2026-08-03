SHELL := /usr/bin/env bash

REPO_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
REPO_FLAKE := $(REPO_DIR)
EXAMPLE_FLAKE := path:$(REPO_DIR)/examples/basic
ISO_PACKAGE ?= installer-iso
ISO_OUTPUT_DIR ?= ./result/iso
ISO_FILE ?= $(ISO_OUTPUT_DIR)/nixos-config-installer.iso

.PHONY: help check check-example build-iso iso-path iso-sha clean-iso update-lock update-lock-nixpkgs update-lock-home-manager update-lock-plasma-manager

help: ## Show available targets
	@grep -E '^[a-zA-Z0-9._-]+:.*## ' $(MAKEFILE_LIST) | sed 's/:.*## /: /' | sort

check: ## Evaluate the public flake and its integrated example
	nix flake check --no-build "$(REPO_FLAKE)"

check-example: ## Evaluate the copyable example against this checkout
	nix flake check --no-build --no-write-lock-file "$(EXAMPLE_FLAKE)" --override-input nixos-config "$(REPO_FLAKE)"

build-iso: ## Build the broad example/recovery installer ISO
	@set -euo pipefail; \
	mkdir -p "$(ISO_OUTPUT_DIR)"; \
	out_path="$$(nix build "$(REPO_FLAKE)#$(ISO_PACKAGE)" --no-link --print-out-paths)"; \
	source_iso="$$(find "$$out_path/iso" -maxdepth 1 -type f -name '*.iso' -print -quit)"; \
	test -n "$$source_iso"; \
	install -m 0644 "$$source_iso" "$(ISO_FILE)"; \
	$(MAKE) iso-sha

iso-path: ## Print the broad ISO path
	@realpath "$(ISO_FILE)"

iso-sha: ## Print the broad ISO SHA256
	sha256sum "$(ISO_FILE)"

clean-iso: ## Remove the stable broad ISO artifact
	rm -f "$(ISO_FILE)"

update-lock: ## Update all flake inputs
	nix flake update

update-lock-nixpkgs: ## Update nixpkgs only
	nix flake update nixpkgs

update-lock-home-manager: ## Update Home Manager only
	nix flake update home-manager

update-lock-plasma-manager: ## Update Plasma Manager only
	nix flake update plasma-manager
