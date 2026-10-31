TF_DIR := terraform
ENV ?= dev

.DEFAULT_GOAL := help

.PHONY: help install lint init fmt validate plan inventory

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

install: ## Install pre-commit hooks (run once after cloning)
	pre-commit install
	pre-commit install --hook-type commit-msg

lint: ## Run all pre-commit hooks against every file
	pre-commit run --all-files

init: ## terraform init against ENV's backend (needs az login)
	terraform -chdir=$(TF_DIR) init -reconfigure -backend-config=backends/$(ENV).hcl

fmt: ## terraform fmt -recursive
	terraform -chdir=$(TF_DIR) fmt -recursive

validate: ## terraform init (no backend) + validate
	terraform -chdir=$(TF_DIR) init -backend=false -input=false
	terraform -chdir=$(TF_DIR) validate

# The token comes from .env; it is exported for terraform only, never echoed.
plan: init ## terraform plan (ENV=dev; CLOUDFLARE_API_TOKEN from .env)
	@set -a; [ -f .env ] && . ./.env; set +a; \
		terraform -chdir=$(TF_DIR) plan -var-file=environments/$(ENV).tfvars

# There is no apply target: cd-terraform applies, from the Actions tab.

inventory: ## List every record in the zone as Cloudflare has it (CLOUDFLARE_API_TOKEN from .env)
	@scripts/inventory.sh
