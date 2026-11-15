# The backup bucket and its retention, against a mocked provider.
mock_provider "cloudflare" {
  mock_data "cloudflare_zone" {
    defaults = {
      zone_id = "0123456789abcdef0123456789abcdef"
      account = { id = "acc0123456789abcdef0123456789ab", name = "test" }
    }
  }
}

variables {
  zone_name                     = "example.com"
  container_apps_default_domain = "env-1234.northeurope.azurecontainerapps.io"
  custom_domain_verification_id = "ABC123"
  backup_bucket_name            = "test-backups"
}

run "bucket_is_in_the_eu_on_the_zones_account" {
  command = plan

  assert {
    condition     = cloudflare_r2_bucket.backups.account_id == "acc0123456789abcdef0123456789ab"
    error_message = "The bucket should be on the account that owns the zone."
  }
  assert {
    condition     = cloudflare_r2_bucket.backups.jurisdiction == "eu"
    error_message = "Backups must stay in the EU jurisdiction."
  }
  assert {
    condition     = output.backup_bucket.endpoint == "https://acc0123456789abcdef0123456789ab.eu.r2.cloudflarestorage.com"
    error_message = "The endpoint should be the account's EU endpoint."
  }
}

run "daily_and_monthly_expire_on_their_own_clocks" {
  command = plan

  assert {
    condition = {
      for r in cloudflare_r2_bucket_lifecycle.backups.rules :
      r.conditions.prefix => r.delete_objects_transition.condition.max_age
      } == {
      "daily/"   = 30 * 86400
      "monthly/" = 365 * 86400
    }
    error_message = "daily/ should expire after 30 days and monthly/ after 365."
  }
  assert {
    condition     = alltrue([for r in cloudflare_r2_bucket_lifecycle.backups.rules : r.enabled])
    error_message = "Every retention rule should be enabled."
  }
}

run "monthly_must_outlive_daily" {
  command = plan

  variables {
    backup_daily_retention_days   = 30
    backup_monthly_retention_days = 30
  }

  expect_failures = [var.backup_monthly_retention_days]
}

run "daily_keeps_at_least_a_week" {
  command = plan

  variables {
    backup_daily_retention_days = 6
  }

  expect_failures = [var.backup_daily_retention_days]
}

run "retention_is_whole_days" {
  command = plan

  variables {
    backup_daily_retention_days = 7.5
  }

  expect_failures = [var.backup_daily_retention_days]
}

run "bucket_name_follows_r2_rules" {
  command = plan

  variables {
    backup_bucket_name = "JW_App_Backups"
  }

  expect_failures = [var.backup_bucket_name]
}
