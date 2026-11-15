# Off-Azure backups of the apps' documents (finances, gym-log, career). Each
# app's scheduled backup writes an age-encrypted copy to `daily/<repo>/`, plus
# one a month to `monthly/<repo>/`. The lifecycle below is the whole retention
# policy: nothing else deletes from this bucket.
#
# R2 is account-level, so the provider token needs Account·Workers R2
# Storage·Edit on top of its zone permissions, and R2 must already be turned
# on for the account (a dashboard step that asks for a payment method). The
# jurisdiction pins the objects to the EU; it cannot be changed once the
# bucket exists.
#
# prevent_destroy: anything that would replace the bucket (a new name, a new
# jurisdiction) fails the plan instead of reaching apply. R2 also refuses to
# delete a bucket that still holds objects.
resource "cloudflare_r2_bucket" "backups" {
  account_id    = local.account_id
  name          = var.backup_bucket_name
  jurisdiction  = local.backup_jurisdiction
  storage_class = "Standard"

  lifecycle {
    prevent_destroy = true
  }
}

resource "cloudflare_r2_bucket_lifecycle" "backups" {
  account_id   = local.account_id
  bucket_name  = cloudflare_r2_bucket.backups.name
  jurisdiction = cloudflare_r2_bucket.backups.jurisdiction

  rules = [for prefix, days in local.backup_retention_days : {
    id         = "expire-${trimsuffix(prefix, "/")}"
    enabled    = true
    conditions = { prefix = prefix }
    delete_objects_transition = {
      condition = { type = "Age", max_age = days * 86400 }
    }
    abort_multipart_uploads_transition = {
      condition = { type = "Age", max_age = 86400 }
    }
  }]
}
