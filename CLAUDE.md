# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo does

Terraform for the DNS records in the `jaywithers.uk` Cloudflare zone, through
the `cloudflare/cloudflare` provider (v5). Records only: zone settings, the
gym-log Cloudflare Tunnel and its Access application stay manual in the
dashboard. Made from `template-repo-terraform-root`; the template's reusable
Azure module, its example and its stg/prd environments are gone, and
`terraform/` is a single root configuration with one environment, `dev`.

## Terraform layout

- `terraform/environments/dev.tfvars` is where records change. `app_domains`
  (subdomain => container app) generates each app's CNAME and `asuid` TXT;
  `resend_domains` (subdomain, `@` for the apex) generates each Resend
  domain's `resend._domainkey` TXT and `send`/`rsend` CNAMEs; `records` takes
  anything else. `locals.tf` expands all three into `local.records`, keyed
  `<TYPE> <name>`.
- **App CNAMEs must stay DNS only** (`proxied = false`). The Azure managed
  certificate on each app validates against the CNAME; a proxied record
  breaks validation and renewal.
- **Names are written in full and TXT values quoted** in `main.tf`, because
  that's how Cloudflare stores them. A relative name or a bare TXT value
  plans a change on every run.
- **Leave out the tunnel's own CNAMEs.** When gym-log's home deploy moves
  `health` onto the tunnel, the tunnel writes that record itself, so remove
  `health` from `app_domains` in the same change, or Terraform and the
  dashboard will fight over it.
- The verification ID and default domain of `cae-platform-dev` are literals
  in `dev.tfvars`, not looked up: this repo's identity can reach its own
  state container and nothing else in Azure.
- To adopt a record made in the dashboard, add it to `dev.tfvars` and an
  `import` block in `imports.tf` (`make inventory` gives its ID; the id is
  `<zone id>/<record id>`), then delete the block once applied. While one is
  there, `terraform test` fails: the import targets a key the tests'
  variables don't produce.
- `terraform/tests/records.tftest.hcl` checks how the three inputs expand,
  against a mocked provider (`make test`, and the `terraform / Test` job).
- **File layout is enforced** by `scripts/check-tf-standards.sh`:
  `locals`/`variable`/`output`/`data` blocks in `locals.tf`/`variables.tf`/
  `outputs.tf`/`data.tf` (or `<kind>.<topic>.tf`), `terraform{}`/`provider{}`
  in `versions.tf`. The script is a verbatim copy of
  `template-repo-terraform-root`'s; re-copy rather than editing it here.

## Auth

- **State:** the `azurerm` backend in `sttfsharedjw`, container `cloudflare`.
  github-repos creates the container and a state-only identity federated to
  this repo's `dev` environment. Locally, `az login`.
- **Cloudflare:** `CLOUDFLARE_API_TOKEN`, a token with Zone·DNS·Edit and
  Zone·Zone·Read on `jaywithers.uk` only. Locally from the gitignored `.env`
  (copied from `.env.example`); in CI from the secret of that name on the
  `dev` environment, never a repository secret. Never put it on a command
  line.

## Commands

`make` with no target prints the self-documenting help (the default goal).

```bash
make install           # install pre-commit hooks (run once after cloning)
make lint              # run all pre-commit hooks against every file
make validate          # terraform init (no backend) + validate
make test              # terraform test (mocked provider, no credentials)
make plan              # plan dev (az login, token from .env)
make inventory         # every record in the zone with its ID (token from .env)
```

There is no `make apply`: applies go through cd-terraform.

## Commit messages

Commits must follow [Conventional Commits](https://www.conventionalcommits.org/) — enforced by commitlint at commit-msg time. Examples: `feat: add the support domain`, `fix: unproxy the career CNAME`, `chore: bump the cloudflare provider`.

## Pre-commit config

Hooks are in `.pre-commit-config.yaml` at the repo root. The `no-commit-to-branch` hook blocks direct commits to `main`. `terraform_fmt`/`terraform_validate`/`terraform_docs` come from `antonbabenko/pre-commit-terraform`. TFLint and Checkov are run by local hooks instead of that repo's `terraform_tflint`/`terraform_checkov`: `scripts/tflint-per-env.sh` and `scripts/checkov-per-env.sh` each glob `terraform/environments/*.tfvars` and run their tool once per environment with `--var-file`, so rules that depend on concrete variable values (naming, tags, region-specific checks) are evaluated against what each environment actually deploys — dropping a new environment's tfvars in `terraform/environments/` picks it up automatically, no config change needed. `tflint-per-env.sh` also discovers every directory under `terraform/` containing `.tf` files (not just the module root) since tflint, unlike checkov, doesn't recurse — both scripts prune hidden directories (via `-name '.?*'`, not `-name .terraform` specifically) so any future tool cache directory is excluded too without code changes; don't switch that to `-name '.*'` — it also matches the find root `.` itself and silently prunes everything. `checkov-per-env.sh` deliberately does **not** pass `--download-external-modules` — it was tried (to scan resources created by registry modules like `Azure/naming/azurerm`), but cost ~15s per invocation regardless of caching (checkov's own graph-building overhead, not network time) for zero benefit here, since that module has no resources of its own. Checkov logs a harmless "Failed to download module" warning as a result. The other local hook, `check-tf-standards` (`scripts/check-tf-standards.sh`), enforces the file-layout standards described above.

## CI

Workflows are prefixed `ci-` (pull-request checks), `cd-` (post-merge
delivery) or `schedule-`. Every Terraform one calls a shared workflow in
`jay-withers/workflows` pinned by SHA (v1.21.0+, the first to map
`CLOUDFLARE_API_TOKEN`), and every call to `terraform-deploy.yml` passes
`secrets: inherit`: without it the called job sees no secrets, its own
environment's included, and the provider has no token.

- **ci-pre-commit**: `pre-commit / Pre-commit`, all hooks.
- **ci-terraform**: `terraform / Terraform` (credential-free validate and
  tests), then a
  real plan of dev commented on the PR, behind the always-reporting
  `terraform-plan` gate.
- **cd-terraform**: plans dev on merges touching Terraform and opens a
  `terraform-pending` issue if it has changes; **Actions → cd-terraform → Run
  workflow** applies that plan.
- **schedule-drift**: nightly plan with `drift: true`, recorded as an
  `OpsEvents_CL` row once github-repos gives this repo `send_events`.
- **cd-tag**: semver tag on every merge to `main`.

## GitHub repo settings

Managed by [jay-withers/github-repos](https://github.com/jay-withers/github-repos)'s
`var.repos` (ruleset, required checks) and `state_consumers` (identity, state
container, `dev` environment variables).
