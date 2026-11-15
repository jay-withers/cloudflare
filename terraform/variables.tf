variable "zone_name" {
  description = "The Cloudflare zone every record below is in."
  type        = string
}

variable "container_apps_default_domain" {
  description = "The shared Container Apps environment's default domain (cae-platform-dev). Every app domain's CNAME points at `<container app>.<this>`."
  type        = string
}

variable "custom_domain_verification_id" {
  description = "The shared Container Apps environment's custom domain verification ID. It is the same for every app on the environment, and goes in each app domain's asuid TXT record."
  type        = string
}

variable "app_domains" {
  description = <<-DESCRIPTION
    Custom domains for apps on the shared Container Apps environment, as
    subdomain => container app name. Each one gets a CNAME to the app and an
    asuid TXT record for Azure's ownership check, both DNS only: the managed
    certificate is validated against the CNAME, so proxying it fails
    validation.
  DESCRIPTION
  type        = map(string)
  default     = {}
}

variable "resend_domains" {
  description = <<-DESCRIPTION
    Resend sending domains, keyed by subdomain (`@` for the zone apex). Each
    one gets Resend's three records: the DKIM TXT at `resend._domainkey`, and
    CNAMEs at `send` and `rsend` for its MAIL FROM and return path. `dkim` is
    the TXT value without its quotes. `return_path` is the `rsend` target,
    which depends on the region the domain was added in.
  DESCRIPTION
  type = map(object({
    dkim        = string
    return_path = optional(string, "rsend-euw1.forge.rmta.net")
  }))
  default = {}
}

variable "records" {
  description = <<-DESCRIPTION
    Any other record, keyed by `<TYPE> <name>` to match the generated ones.
    `name` is relative to the zone (`@` for the apex). A TXT `content` is
    written without its quotes. `ttl` 1 means Cloudflare's automatic TTL.
  DESCRIPTION
  type = map(object({
    type     = string
    name     = string
    content  = string
    ttl      = optional(number, 1)
    proxied  = optional(bool, false)
    priority = optional(number)
    comment  = optional(string)
  }))
  default = {}
}

variable "backup_bucket_name" {
  description = "The R2 bucket the apps' encrypted off-Azure backups go to. The bucket has prevent_destroy, so changing this fails the plan."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.backup_bucket_name))
    error_message = "R2 bucket names are 3-63 lowercase letters, digits and hyphens, starting and ending with a letter or digit."
  }
}

variable "backup_daily_retention_days" {
  description = "Days a backup under `daily/` is kept before R2 deletes it."
  type        = number
  default     = 30

  validation {
    condition     = var.backup_daily_retention_days >= 7 && floor(var.backup_daily_retention_days) == var.backup_daily_retention_days
    error_message = "Keep at least a week of daily backups, in whole days."
  }
}

variable "backup_monthly_retention_days" {
  description = "Days a backup under `monthly/` is kept before R2 deletes it."
  type        = number
  default     = 365

  validation {
    condition     = var.backup_monthly_retention_days > var.backup_daily_retention_days && floor(var.backup_monthly_retention_days) == var.backup_monthly_retention_days
    error_message = "Monthly backups must outlive the daily ones, in whole days."
  }
}
