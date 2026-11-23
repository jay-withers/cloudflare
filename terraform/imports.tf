# Adopts each record in local.adopt (var.adopt, filtered in locals.imports.tf) rather than creating
# a duplicate, which Cloudflare would refuse. Only where the lookup finds
# exactly one match: none means there is nothing to adopt (the plan shows a
# create), and an entry left in the list after the apply finds the managed
# record itself, which Terraform skips as already imported. So a forgotten
# entry never breaks a plan.
import {
  for_each = {
    for k in keys(local.adopt) : k => one(data.cloudflare_dns_records.adopt[k].result).id
    if length(data.cloudflare_dns_records.adopt[k].result) == 1
  }

  to = cloudflare_dns_record.this[each.key]
  id = "${data.cloudflare_zone.this.zone_id}/${each.value}"
}
