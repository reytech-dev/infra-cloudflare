# infra-cloudflare

OpenTofu configuration for Cloudflare DNS records that point to
DigitalOcean infrastructure.

## Resources

| Resource | Purpose |
|---|---|
| `data.aws_s3_object.dns_contract` | Reads the DNS contract JSON from S3-compatible storage |
| `cloudflare_dns_record.records` | Creates Cloudflare DNS records from the decoded contract |

## Dependencies

This repository depends on the DNS contract published by
**infra-digitalocean**. The DigitalOcean pipeline must run successfully
before this repository can be applied.

**Important:** This repo only needs read access to the contract object.
It does **not** access the DigitalOcean state file and does **not** use
`terraform_remote_state`.

## Required Secrets

Set these environment variables:

```bash
export CLOUDFLARE_API_TOKEN="..."
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
```

When reading the contract from DigitalOcean Spaces, use your Spaces
access key pair for `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.

## Backend Initialisation

```bash
# Standard AWS S3
tofu init \
  -backend-config="bucket=my-opentofu-state" \
  -backend-config="key=cloudflare/prod.tfstate" \
  -backend-config="region=us-east-1"

# DigitalOcean Spaces
tofu init \
  -backend-config="bucket=my-opentofu-state" \
  -backend-config="key=cloudflare/prod.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="endpoint=https://nyc3.digitaloceanspaces.com" \
  -backend-config="skip_credentials_validation=true" \
  -backend-config="skip_metadata_api_check=true" \
  -backend-config="skip_requesting_account_id=true" \
  -backend-config="force_path_style=true"
```

## Usage

```bash
# Copy and customise variables
cp example.tfvars prod.tfvars
# Edit prod.tfvars with your values

# Plan
tofu plan -var-file=prod.tfvars

# Apply
tofu apply -var-file=prod.tfvars
```

## DNS Records Created

```
app.example.com  -> frontend DigitalOcean IP (A record, proxied)
api.example.com  -> backend DigitalOcean IP  (A record, proxied)
```

## Adding Another DNS Record

No changes are needed in this repository. To add a DNS record:

1. In **infra-digitalocean**, add the new DigitalOcean resource and a
   corresponding entry to `local.dns_records` in `contract.tf`.
2. Run `tofu apply` in **infra-digitalocean** to publish the updated contract.
3. Run `tofu apply` in this repository. The `for_each` loop picks up
   the new record automatically.

## Apply Order

```
1. infra-digitalocean  (must run first – publishes the contract)
2. infra-cloudflare    (this repo – reads the contract)
```

In CI/CD, the Cloudflare pipeline should run only after the
DigitalOcean pipeline has completed successfully.
