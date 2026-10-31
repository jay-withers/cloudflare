#!/usr/bin/env bash
# Lists every DNS record in the zone as Cloudflare has it, one tab-separated
# line each: id, type, name, content, ttl, proxied, priority, comment.
# Compare it with terraform/environments/dev.tfvars to find a record made in
# the dashboard and never brought in, or the record id an `import` block needs.
#
# Reads CLOUDFLARE_API_TOKEN from .env (gitignored, see .env.example) unless
# it is already in the environment. The token is sent only as a request
# header, never echoed.
set -euo pipefail

repo_root=$(git rev-parse --show-toplevel)
zone=${ZONE:-jaywithers.uk}

if [ -z "${CLOUDFLARE_API_TOKEN:-}" ] && [ -f "$repo_root/.env" ]; then
  # shellcheck disable=SC1091
  set -a && . "$repo_root/.env" && set +a
fi
if [ -z "${CLOUDFLARE_API_TOKEN:-}" ]; then
  echo "CLOUDFLARE_API_TOKEN is empty: set it in .env (see .env.example)." >&2
  exit 1
fi

api() {
  curl -fsS -H @- "https://api.cloudflare.com/client/v4/$1" <<<"Authorization: Bearer $CLOUDFLARE_API_TOKEN"
}

zone_id=$(api "zones?name=$zone" | jq -r '.result[0].id // empty')
if [ -z "$zone_id" ]; then
  echo "Zone $zone not found, or the token can't read it." >&2
  exit 1
fi
echo "# zone $zone $zone_id"

page=1
while :; do
  body=$(api "zones/$zone_id/dns_records?per_page=100&page=$page")
  jq -r '.result[] | [.id, .type, .name, .content, .ttl, .proxied, (.priority // ""), (.comment // "")] | @tsv' <<<"$body"
  [ "$page" -ge "$(jq -r '.result_info.total_pages' <<<"$body")" ] && break
  page=$((page + 1))
done
