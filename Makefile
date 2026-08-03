SHELL := /usr/bin/env bash

REPO_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
REPO_FLAKE := path:$(REPO_DIR)
EXAMPLE_FLAKE := path:$(REPO_DIR)/examples/basic

.PHONY: help check check-example update-lock update-lock-nixpkgs update-lock-home-manager update-lock-plasma-manager

help: ## Show available targets
	@grep -E '^[a-zA-Z0-9._-]+:.*## ' $(MAKEFILE_LIST) | sed 's/:.*## /: /' | sort

check: ## Evaluate the public flake and its integrated example
	nix flake check --no-build "$(REPO_FLAKE)"

check-example: ## Evaluate the copyable example against this checkout
	nix flake check --no-build --no-write-lock-file "$(EXAMPLE_FLAKE)" --override-input nixos-config "$(REPO_FLAKE)"

update-lock: ## Update all flake inputs
	nix flake update

update-lock-nixpkgs: ## Update nixpkgs only
	nix flake update nixpkgs

update-lock-home-manager: ## Update Home Manager only
	nix flake update home-manager

update-lock-plasma-manager: ## Update Plasma Manager only
	nix flake update plasma-manager
