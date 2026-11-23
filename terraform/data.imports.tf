# The dashboard copy of each record in local.adopt. Matched on exact content
# as well as name and type, because several records can share a name (the
# apex, especially), and quoted the way main.tf writes a TXT value, which is
# how Cloudflare stores it.
data "cloudflare_dns_records" "adopt" {
  for_each = local.adopt

  zone_id   = data.cloudflare_zone.this.zone_id
  type      = each.value.type
  name      = { exact = each.value.name == "@" ? var.zone_name : "${each.value.name}.${var.zone_name}" }
  content   = { exact = each.value.type == "TXT" ? "\"${each.value.content}\"" : each.value.content }
  max_items = 2
}
