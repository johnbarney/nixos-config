SHELL := /usr/bin/env bash

REPO_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
REPO_FLAKE := path:$(REPO_DIR)

.PHONY: help check update-lock update-lock-nixpkgs update-lock-home-manager update-lock-plasma-manager

help: ## Show available targets
	@grep -E '^[a-zA-Z0-9._-]+:.*## ' $(MAKEFILE_LIST) | sed 's/:.*## /: /' | sort

check: ## Run flake checks (no build)
	nix flake check --no-build "$(REPO_FLAKE)"

update-lock: ## Update all flake inputs
	nix flake update

update-lock-nixpkgs: ## Update nixpkgs lock input only
	nix flake lock --update-input nixpkgs

update-lock-home-manager: ## Update home-manager lock input only
	nix flake lock --update-input home-manager

update-lock-plasma-manager: ## Update plasma-manager lock input only
	nix flake lock --update-input plasma-manager
