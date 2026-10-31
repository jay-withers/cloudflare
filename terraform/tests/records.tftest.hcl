# How app_domains, resend_domains and records expand into records, against a
# mocked provider: no Cloudflare token or Azure auth needed.
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
  app_domains                   = { app = "ca-app-dev" }
  resend_domains = {
    "@"   = { dkim = "p=APEX" }
    "app" = { dkim = "p=APP", return_path = "rsend.forge.rmta.net" }
  }
  records = {
    "MX @" = { type = "MX", name = "@", content = "mail.example.com", priority = 10 }
  }
}

run "app_domain_gets_cname_and_asuid" {
  command = plan

  assert {
    condition     = cloudflare_dns_record.this["CNAME app"].name == "app.example.com"
    error_message = "The app CNAME should be the full name."
  }
  assert {
    condition     = cloudflare_dns_record.this["CNAME app"].content == "ca-app-dev.env-1234.northeurope.azurecontainerapps.io"
    error_message = "The app CNAME should point at the container app on the environment."
  }
  assert {
    condition     = cloudflare_dns_record.this["CNAME app"].proxied == false
    error_message = "App CNAMEs must be DNS only, or the managed certificate fails validation."
  }
  assert {
    condition     = cloudflare_dns_record.this["TXT asuid.app"].content == "\"ABC123\""
    error_message = "The asuid TXT should carry the quoted verification ID."
  }
}

run "resend_apex_has_no_trailing_dot" {
  command = plan

  assert {
    condition     = cloudflare_dns_record.this["CNAME send"].name == "send.example.com"
    error_message = "The apex domain's send CNAME should be send.<zone>."
  }
  assert {
    condition     = cloudflare_dns_record.this["TXT resend._domainkey"].content == "\"p=APEX\""
    error_message = "The apex DKIM should be at resend._domainkey.<zone>, quoted."
  }
  assert {
    condition     = cloudflare_dns_record.this["CNAME rsend"].content == "rsend-euw1.forge.rmta.net"
    error_message = "return_path should default to the eu-west-1 target."
  }
}

run "resend_subdomain_and_return_path_override" {
  command = plan

  assert {
    condition     = cloudflare_dns_record.this["CNAME rsend.app"].name == "rsend.app.example.com"
    error_message = "A subdomain's records should sit under it."
  }
  assert {
    condition     = cloudflare_dns_record.this["CNAME rsend.app"].content == "rsend.forge.rmta.net"
    error_message = "return_path should override the default."
  }
}

run "extra_records_pass_through" {
  command = plan

  assert {
    condition     = cloudflare_dns_record.this["MX @"].name == "example.com" && cloudflare_dns_record.this["MX @"].priority == 10
    error_message = "An extra apex MX should keep its priority and resolve @ to the zone."
  }
  assert {
    condition     = length(cloudflare_dns_record.this) == 9
    error_message = "1 app (2) + 2 Resend domains (6) + 1 extra should be 9 records."
  }
}
