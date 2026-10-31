terraform {
  required_version = ">= 1.7"

  # Partial: per-environment values live in backends/<env>.hcl.
  #   terraform init -backend-config=backends/dev.hcl
  # Anything not touching state must init with -backend=false, or this prompts.
  backend "azurerm" {}

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.28"
    }
  }
}

# Token comes from CLOUDFLARE_API_TOKEN (the provider's default) - never
# hardcode it here. Locally that's .env (see .env.example); in CI it's the
# secret of the same name on this repo's `dev` environment, which the shared
# terraform-deploy.yml maps into plan and apply.
provider "cloudflare" {}
