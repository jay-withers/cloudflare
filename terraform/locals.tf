locals {
  # `career` -> `.career`, `@` -> "", for building names under a subdomain.
  resend_suffix = { for k, _ in var.resend_domains : k => k == "@" ? "" : ".${k}" }

  # Every record, keyed by `<TYPE> <name>` so a key reads like the record and
  # two types on one name never collide. Names are relative to the zone.
  records = merge(
    merge([for sub, app in var.app_domains : {
      "CNAME ${sub}" = {
        type    = "CNAME"
        name    = sub
        content = "${app}.${var.container_apps_default_domain}"
        ttl     = 1
      }
      "TXT asuid.${sub}" = {
        type    = "TXT"
        name    = "asuid.${sub}"
        content = var.custom_domain_verification_id
        ttl     = 1
      }
    }]...),
    merge([for k, d in var.resend_domains : {
      "TXT resend._domainkey${local.resend_suffix[k]}" = {
        type    = "TXT"
        name    = "resend._domainkey${local.resend_suffix[k]}"
        content = d.dkim
        ttl     = 3600
      }
      "CNAME send${local.resend_suffix[k]}" = {
        type    = "CNAME"
        name    = "send${local.resend_suffix[k]}"
        content = "send.forge.rmta.net"
        ttl     = 3600
      }
      "CNAME rsend${local.resend_suffix[k]}" = {
        type    = "CNAME"
        name    = "rsend${local.resend_suffix[k]}"
        content = d.return_path
        ttl     = 3600
      }
    }]...),
    var.records,
  )
}
