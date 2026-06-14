output "dns_records" {
  description = "Map of DNS record names to their Cloudflare resource attributes"
  value = {
    for k, r in cloudflare_dns_record.records : k => {
      name    = r.hostname
      type    = r.type
      content = r.content
      proxied = r.proxied
      ttl     = r.ttl
    }
  }
}

output "contract_environment" {
  description = "Environment extracted from the DNS contract"
  value       = local.contract.environment
}

output "contract_schema_version" {
  description = "Schema version extracted from the DNS contract"
  value       = local.contract.schema_version
}
