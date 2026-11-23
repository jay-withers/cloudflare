# cloudflare

Terraform for the DNS records in the `jaywithers.uk` Cloudflare zone: every
app's custom-domain CNAME and `asuid` TXT, and every Resend sending domain's
records. Until this repo existed they were all made by hand in the dashboard.
It also holds the R2 bucket for the apps' encrypted off-Azure backups.

The zone's own settings stay manual in the dashboard.

What it manages today (`terraform/environments/dev.tfvars`):

- **App custom domains** on the shared Container Apps environment:
  `career`, `finances`, `health`, `marketagent`, `observability`
  and `support`.
- **Resend sending domains:** the apex, `career`, `finances`, `health` and
  `send`.
- **The `jw-app-backups` R2 bucket** (below).

## First-time setup

Tools come from mise ([toolchain](https://github.com/jay-withers/toolchain)
sets a machine up once). Then:

```bash
make install            # mise install + pre-commit and commit-msg hooks
```

## Backup bucket

`main.r2.tf` makes `jw-app-backups`, an R2 bucket in the EU jurisdiction.
The apps' scheduled backups write age-encrypted copies of their documents
to `daily/<repo>/` and `monthly/<repo>/`. R2 deletes them after 30 and 365
days. That lifecycle is the only retention policy.

Before the first apply, turn R2 on for the account in the dashboard (it asks
for a payment method; this usage stays inside the free tier) and add
**Account · Workers R2 Storage · Edit** to the token below.

## Adding a record

Edit `terraform/environments/dev.tfvars` and open a PR. The PR plan shows the
change; once it merges, cd-terraform opens a `terraform-pending` issue, and
**Actions → cd-terraform → Run workflow** applies it.

- **An app's custom domain:** one line in `app_domains`,
  `subdomain = "<container app name>"`. That gives the CNAME and the `asuid`
  TXT, both DNS only: the Azure managed certificate validates against the
  CNAME, and proxying it breaks validation. The app repo still owns the
  Azure half (custom domain and certificate) and applies it after this.
- **A Resend sending domain:** add the domain in the Resend dashboard, then an
  entry in `resend_domains` keyed by subdomain (`@` for the apex) with the
  DKIM value Resend shows, without its quotes. That gives
  `resend._domainkey`, `send` and `rsend`.
- **Anything else:** an entry in `records`, keyed `<TYPE> <name>`.

**Adopting a record made in the dashboard:** add it to `dev.tfvars`, and its
key to `local.adopt` in `terraform/locals.imports.tf`. The pull request's
plan looks the record's ID up by name, type and content and imports it,
rather than creating a duplicate Cloudflare would refuse. Empty the list once
it's applied.

## Running it locally

```bash
make validate           # terraform init (no backend) + validate
make test               # terraform test against a mocked provider, no credentials
make lint               # every pre-commit hook (fmt, docs, tflint, checkov, layout)

cp .env.example .env    # then paste a token into CLOUDFLARE_API_TOKEN
az login                # the state backend is Azure storage (sttfsharedjw/cloudflare)
make plan
make inventory          # every record in the zone, as Cloudflare has it
```

`make` with no target lists every target. The tests
(`terraform/tests/`) check how `app_domains`, `resend_domains` and `records`
expand into records, and the bucket's jurisdiction and retention.

The token needs **Zone · DNS · Edit** and **Zone · Zone · Read** on
`jaywithers.uk`, and **Account · Workers R2 Storage · Edit** for the backup
bucket. CI uses the same kind of token from the
`CLOUDFLARE_API_TOKEN` secret on this repo's `dev` environment. There is no
`make apply`: applies go through cd-terraform.

## CI/CD

Each workflow is a thin caller of a shared one in
[jay-withers/workflows](https://github.com/jay-withers/workflows):

- **ci-pre-commit** and **ci-terraform** on PRs: every hook, then validate,
  `terraform test` and a real plan of dev commented on the PR.
- **ci-codeql** scans the workflows.
- **cd-terraform** plans on merge and opens the `terraform-pending` issue;
  running it from the Actions tab applies.
- **cd-tag** tags a semver release on every merge to `main`.
- **manual-terraform-unlock** releases a stuck state lock: run it by hand
  with the lock ID from an "Error acquiring the state lock" message.

The repo's settings, required checks, `dev` environment and state identity
are managed by [github-repos](https://github.com/jay-withers/github-repos).

## Drift

`schedule-drift` plans nightly, so a record edited in the dashboard shows up
as drift. Put it back by running cd-terraform, or bring the change into
`dev.tfvars`. `make inventory` lists what's live, with each record's ID. A
record made in the dashboard that isn't in `dev.tfvars` won't show as drift:
compare the inventory with `dev.tfvars` to find one, then adopt it through
`local.adopt` (above).
