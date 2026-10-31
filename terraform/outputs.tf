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
