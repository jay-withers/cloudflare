# Adopting dashboard records (locals.imports.tf): an import is planned only
# for a key in local.adopt that the configuration actually has, so the tests'
# variables plan none and the mocked provider is never asked to import.
#
# The import itself isn't tested here: a mocked provider can't import, and
# overriding cloudflare_dns_records' list-nested `result` fails to convert.
# ci-terraform's real plan of dev on the pull request is its test.
mock_provider "cloudflare" {
  mock_data "cloudflare_zone" {
    defaults = {
      zone_id = "0123456789abcdef0123456789abcdef"
    }
  }
}

variables {
  zone_name                     = "example.com"
  container_apps_default_domain = "env-1234.northeurope.azurecontainerapps.io"
  custom_domain_verification_id = "ABC123"
  backup_bucket_name            = "test-backups"
  app_domains                   = {}
  resend_domains                = {}
  records                       = {}
}

run "nothing_to_adopt_without_the_record" {
  command = plan

  assert {
    condition     = length(local.adopt) == 0
    error_message = "A key in the adopt list that the configuration lacks must plan no import."
  }
}
