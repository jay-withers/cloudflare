# terraform

The root configuration: one `cloudflare_dns_record` per entry in
`local.records`, built from `app_domains`, `resend_domains` and `records` in
`environments/dev.tfvars`, plus the `jw-app-backups` R2 bucket and its
retention (`main.r2.tf`). State is in the shared `sttfsharedjw` account, in
the `cloudflare` container (`backends/dev.hcl`). See the repo README for how
to add a record.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | ~> 5.28 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | ~> 5.28 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [cloudflare_dns_record.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/dns_record) | resource |
| [cloudflare_r2_bucket.backups](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/r2_bucket) | resource |
| [cloudflare_r2_bucket_lifecycle.backups](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/r2_bucket_lifecycle) | resource |
| [cloudflare_zone.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/data-sources/zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_app_domains"></a> [app\_domains](#input\_app\_domains) | Custom domains for apps on the shared Container Apps environment, as<br/>subdomain => container app name. Each one gets a CNAME to the app and an<br/>asuid TXT record for Azure's ownership check, both DNS only: the managed<br/>certificate is validated against the CNAME, so proxying it fails<br/>validation. | `map(string)` | `{}` | no |
| <a name="input_backup_bucket_name"></a> [backup\_bucket\_name](#input\_backup\_bucket\_name) | The R2 bucket the apps' encrypted off-Azure backups go to. The bucket has prevent\_destroy, so changing this fails the plan. | `string` | n/a | yes |
| <a name="input_backup_daily_retention_days"></a> [backup\_daily\_retention\_days](#input\_backup\_daily\_retention\_days) | Days a backup under `daily/` is kept before R2 deletes it. | `number` | `30` | no |
| <a name="input_backup_monthly_retention_days"></a> [backup\_monthly\_retention\_days](#input\_backup\_monthly\_retention\_days) | Days a backup under `monthly/` is kept before R2 deletes it. | `number` | `365` | no |
| <a name="input_container_apps_default_domain"></a> [container\_apps\_default\_domain](#input\_container\_apps\_default\_domain) | The shared Container Apps environment's default domain (cae-platform-dev). Every app domain's CNAME points at `<container app>.<this>`. | `string` | n/a | yes |
| <a name="input_custom_domain_verification_id"></a> [custom\_domain\_verification\_id](#input\_custom\_domain\_verification\_id) | The shared Container Apps environment's custom domain verification ID. It is the same for every app on the environment, and goes in each app domain's asuid TXT record. | `string` | n/a | yes |
| <a name="input_records"></a> [records](#input\_records) | Any other record, keyed by `<TYPE> <name>` to match the generated ones.<br/>`name` is relative to the zone (`@` for the apex). A TXT `content` is<br/>written without its quotes. `ttl` 1 means Cloudflare's automatic TTL. | <pre>map(object({<br/>    type     = string<br/>    name     = string<br/>    content  = string<br/>    ttl      = optional(number, 1)<br/>    proxied  = optional(bool, false)<br/>    priority = optional(number)<br/>    comment  = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_resend_domains"></a> [resend\_domains](#input\_resend\_domains) | Resend sending domains, keyed by subdomain (`@` for the zone apex). Each<br/>one gets Resend's three records: the DKIM TXT at `resend._domainkey`, and<br/>CNAMEs at `send` and `rsend` for its MAIL FROM and return path. `dkim` is<br/>the TXT value without its quotes. `return_path` is the `rsend` target,<br/>which depends on the region the domain was added in. | <pre>map(object({<br/>    dkim        = string<br/>    return_path = optional(string, "rsend-euw1.forge.rmta.net")<br/>  }))</pre> | `{}` | no |
| <a name="input_zone_name"></a> [zone\_name](#input\_zone\_name) | The Cloudflare zone every record below is in. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_backup_bucket"></a> [backup\_bucket](#output\_backup\_bucket) | The backup bucket's name and its EU S3 endpoint, for the apps' backup workflows. |
| <a name="output_records"></a> [records](#output\_records) | Every managed record's name, type and content, keyed as in local.records. |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | The zone's ID, for an `import` block's `<zone id>/<record id>`. |
<!-- END_TF_DOCS -->
