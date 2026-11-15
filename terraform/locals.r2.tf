locals {
  # The account the zone belongs to, which owns the R2 bucket too. Read off the
  # zone so no account ID literal is needed.
  account_id = data.cloudflare_zone.this.account.id

  # Where the backups are guaranteed to be stored. It is also in the S3
  # endpoint's host name, so the output is built from this too.
  backup_jurisdiction = "eu"

  # Key prefix => days an object under it is kept.
  backup_retention_days = {
    "daily/"   = var.backup_daily_retention_days
    "monthly/" = var.backup_monthly_retention_days
  }
}
