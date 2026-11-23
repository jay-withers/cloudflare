locals {
  # Records made in the dashboard that are in dev.tfvars but not yet in state,
  # keyed as in local.records. imports.tf adopts each one, finding its ID by
  # name, type and content (data.imports.tf), so no record ID is copied by
  # hand and no local token is needed: CI's plan does the lookup.
  #
  # Filtered to keys local.records has, so the tests, whose variables don't
  # produce them, plan no import. Empty this list once the apply has run.
  adopt = {
    for k in ["TXT @ google-site-verification"] : k => local.records[k]
    if contains(keys(local.records), k)
  }
}
