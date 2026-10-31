zone_name = "jaywithers.uk"

# cae-platform-dev's default domain and custom domain verification ID
# (azure-container-apps). Copied rather than looked up: this root's identity
# has no Azure access beyond its own state.
container_apps_default_domain = "bravesand-91aa0544.northeurope.azurecontainerapps.io"
custom_domain_verification_id = "E64EA34AC0738227E2A071883B066A3FE3D894DBF273542D6C7F2CDC801131EA"

# Subdomain => container app. Each needs its own custom domain and managed
# certificate in its app repo; these are only the DNS half.
app_domains = {
  career        = "ca-career-dev"
  finances      = "ca-finances-dev"
  health        = "ca-gymlog-dev"
  marketagent   = "ca-marketagent-dev-dashboard"
  observability = "ca-observability-dev"
  support       = "ca-supportagent-dev"
}

# Each one is also a verified domain in the Resend dashboard, which shows the
# DKIM value when the domain is added there.
resend_domains = {
  "@" = {
    dkim = "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCuoAicJE3xaZAzC5zyN7Dl4AO0augGXtbL6s3AiAKzDG+xNhM3EDhA4d98eCN0+LuPieDylq6z81f1SR5hcCX0VnyCxS42QzLtCQ7MyU5rOEanKeKYuMsrA7BiiJKklEnWOO0+gPEgn0fnHqqvZTiK6KgqFV1rVIZ2f0rxHfApCwIDAQAB"
  }
  "career" = {
    dkim = "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC2wkB1cReDmfMd9LJQZt8WEuO6J39FSz9uuvhgeJeTtOfLNQti/dMz/29/PAp9eCJ+zRW6sXtAOLU6TBx2zDzPVZUsmjj++d7KT4BcL0YvZkYLQOgxMQ9mZ2EAImE41tWP9WB52tEn69h4+x9O+w7ke9Uf8jCoa3hbb1TOWoIjfQIDAQAB"
  }
  "finances" = {
    dkim = "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCbleSeGtwcSteprmh992E6OpUXXP36rcdASXAYopPPkQsIKg+/shHFLRESdA5mlEvMEfh5pKUAsTHkyOrv2N88+YFo4xg9TsSI0arL7iCT5XnlYv8reaW0naCJgaCzDnQwf8tthVnCN+LkcyrTDobXMhZ2cdxPMHEnekAqJqwTkwIDAQAB"
  }
  "health" = {
    dkim = "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC+1peG8eyxd4amhE3CO/a1H0thFjU1oL1MY+SJpx7AfStuNsxMVUVg7HszbWuZaTYxmcon/CwdkBwS6tt8zgRBwQ9ap4ShKF9RuBb/MObxOpmniVYHWmPwklrLa9T3OmJ11f6MG0f6zCt9Tsnt+lcVSOfwLJ4DhxZFgyyBAYNqsQIDAQAB"
  }
  "send" = {
    dkim = "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC8tdky1KjawpzVmGIXHRxUNsrwUl3Vj4XnJ49AFp6GW1H8WNjoBRLJYFGEy649Pc9/S474E8SaVi9LysSqXjLrGfDwSlIRe1c5SJyppUgM0Ki0m0rJMK7UfnQgv+8RjTocfo2Olwf3mkr4TuO3nH2nScTDWUlXSXrgGjmzH5HBnQIDAQAB"
    # No region in its return path, unlike the others.
    return_path = "rsend.forge.rmta.net"
  }
}
