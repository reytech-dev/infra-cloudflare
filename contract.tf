# ── Read DNS contract from S3-compatible storage ──
#
# The contract is published by the infra-digitalocean repository.
# This data source reads the contract object and decodes it.
# No access to the DigitalOcean state file is required.

data "aws_s3_object" "dns_contract" {
  bucket = var.contract_bucket
  key    = var.contract_key
}

locals {
  contract = jsondecode(data.aws_s3_object.dns_contract.body)
  records  = local.contract.records
}
