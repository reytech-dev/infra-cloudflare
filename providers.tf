provider "cloudflare" {
  # Token read from CLOUDFLARE_API_TOKEN environment variable
}

provider "aws" {
  region = var.contract_storage_region

  skip_credentials_validation = var.s3_skip_credentials_validation
  skip_metadata_api_check     = var.s3_skip_metadata_api_check
  skip_requesting_account_id  = var.s3_skip_requesting_account_id
  force_path_style            = var.s3_force_path_style

  endpoints {
    s3 = var.s3_endpoint
  }
}
