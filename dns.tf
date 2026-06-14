# ── Cloudflare DNS records ──
#
# Uses for_each over the decoded contract records so adding
# more DNS records later only requires updating the contract
# in the infra-digitalocean repository.

resource "cloudflare_dns_record" "records" {
  for_each = local.records

  zone_id = var.cloudflare_zone_id
  name    = each.value.name
  type    = each.value.type
  content = each.value.content
  proxied = each.value.proxied
  ttl     = each.value.ttl
}
