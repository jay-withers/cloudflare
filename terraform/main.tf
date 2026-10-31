# Every DNS record in the zone. Anything Cloudflare writes for itself (a
# tunnel's public hostname, say) must stay out of here, or the two will fight
# over it.
#
# Names are written in full (Cloudflare reports them that way, so a relative
# name would plan a change every time) and TXT values get the quotes
# Cloudflare stores them with, for the same reason.
resource "cloudflare_dns_record" "this" {
  for_each = local.records

  zone_id  = data.cloudflare_zone.this.zone_id
  type     = each.value.type
  name     = each.value.name == "@" ? var.zone_name : "${each.value.name}.${var.zone_name}"
  content  = each.value.type == "TXT" ? "\"${each.value.content}\"" : each.value.content
  ttl      = each.value.ttl
  proxied  = try(each.value.proxied, false)
  priority = try(each.value.priority, null)
  comment  = try(each.value.comment, null)
}
