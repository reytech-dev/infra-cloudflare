terraform {
  backend "s3" {
    # Configure these via -backend-config or a backend config file:
    #
    #   tofu init \
    #     -backend-config="bucket=my-opentofu-state" \
    #     -backend-config="key=cloudflare/prod.tfstate" \
    #     -backend-config="region=us-east-1"
    #
    # For S3-compatible storage (e.g. DigitalOcean Spaces), also set:
    #   -backend-config="endpoint=https://nyc3.digitaloceanspaces.com"
    #   -backend-config="skip_credentials_validation=true"
    #   -backend-config="skip_metadata_api_check=true"
    #   -backend-config="skip_requesting_account_id=true"
    #   -backend-config="force_path_style=true"

    encrypt        = true
    use_lockfile   = true
  }
}
