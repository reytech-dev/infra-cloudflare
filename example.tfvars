# ── infra-cloudflare example tfvars ──
# Copy to terraform.tfvars or prod.tfvars and customize.

environment        = "prod"
cloudflare_zone_id = "abc123..."
contract_bucket    = "my-opentofu-contracts"
contract_key       = "contracts/prod/digitalocean-dns-targets.json"

# Use these when reading the contract from DigitalOcean Spaces
# contract_storage_region       = "us-east-1"
# s3_endpoint                   = "https://nyc3.digitaloceanspaces.com"
# s3_skip_credentials_validation = true
# s3_skip_metadata_api_check     = true
# s3_skip_requesting_account_id  = true
# s3_force_path_style            = true
