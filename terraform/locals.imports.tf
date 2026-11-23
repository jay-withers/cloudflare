locals {
  # The records in var.adopt that the configuration has, keyed as in
  # local.records. imports.tf adopts each one, finding its ID by name, type
  # and content (data.imports.tf), so no record ID is copied by hand and no
  # local token is needed: CI's plan does the lookup.
  #
  # A key the configuration lacks is dropped rather than failing, so the
  # tests, whose variables don't produce dev's records, plan no import.
  adopt = {
    for k in var.adopt : k => local.records[k]
    if contains(keys(local.records), k)
  }
}
