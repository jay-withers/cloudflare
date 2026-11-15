output "zone_id" {
  description = "The zone's ID, for an `import` block's `<zone id>/<record id>`."
  value       = data.cloudflare_zone.this.zone_id
}

output "records" {
  description = "Every managed record's name, type and content, keyed as in local.records."
  value = { for k, r in cloudflare_dns_record.this : k => {
    name    = r.name
    type    = r.type
    content = r.content
  } }
}

output "backup_bucket" {
  description = "The backup bucket's name and its EU S3 endpoint, for the apps' backup workflows."
  value = {
    name     = cloudflare_r2_bucket.backups.name
    endpoint = "https://${local.account_id}.${local.backup_jurisdiction}.r2.cloudflarestorage.com"
  }
}
