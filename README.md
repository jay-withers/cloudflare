# cloudflare

Terraform for the DNS records in the `jaywithers.uk` Cloudflare zone: every
app's custom-domain CNAME and `asuid` TXT, and every Resend sending domain's
records. Until this repo existed they were all made by hand in the dashboard.
It also holds the R2 bucket for the apps' encrypted off-Azure backups.

The zone's own settings stay manual in the dashboard.

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

## Running it locally

```bash
cp .env.example .env    # then paste a token into CLOUDFLARE_API_TOKEN
az login                # the state backend is Azure storage
make plan
make inventory          # every record in the zone, as Cloudflare has it
```

The token needs **Zone · DNS · Edit** and **Zone · Zone · Read** on
`jaywithers.uk`, and **Account · Workers R2 Storage · Edit** for the backup
bucket. CI uses the same kind of token from the
`CLOUDFLARE_API_TOKEN` secret on this repo's `dev` environment. There is no
`make apply`: applies go through cd-terraform.

## Drift

`schedule-drift` plans nightly, so a record edited in the dashboard shows up
as drift. Put it back by running cd-terraform, or bring the change into
`dev.tfvars`. `make inventory` lists what's live, with each record's ID, which
is also what an `import` block needs to adopt a record made in the dashboard.
