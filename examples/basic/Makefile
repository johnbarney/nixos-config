SHELL := /usr/bin/env bash

HOST ?= example
REPO_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
REPO_FLAKE := path:$(REPO_DIR)

.PHONY: help check switch test-switch update-lock update-base

help: ## Show available targets
	@grep -E '^[a-zA-Z0-9._-]+:.*## ' $(MAKEFILE_LIST) | sed 's/:.*## /: /' | sort

check: ## Evaluate the flake without building
	nix flake check --no-build "$(REPO_FLAKE)"

switch: ## Build and switch HOST (uses sudo)
	sudo nixos-rebuild switch --flake "$(REPO_FLAKE)#$(HOST)"

test-switch: ## Build and activate HOST temporarily (uses sudo)
	sudo nixos-rebuild test --flake "$(REPO_FLAKE)#$(HOST)"

update-lock: ## Update all flake inputs
	nix flake update

update-base: ## Update nixos-config only
	nix flake update nixos-config
