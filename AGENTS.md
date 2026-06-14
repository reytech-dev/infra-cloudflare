# AGENTS.md — infra-cloudflare

Instructions for AI agents using this OpenTofu repository.

## Overview

This repository creates Cloudflare DNS records that point to
DigitalOcean infrastructure. It reads a **DNS contract JSON** from
S3-compatible object storage — a contract published by the
`infra-digitalocean` repository.

This repo does **not** use `terraform_remote_state` and has **no**
access to the DigitalOcean state file. It only needs read access to
the contract S3 object.

**Apply order:** Run this repo **after** `infra-digitalocean`.

---

## Prerequisites

The `infra-digitalocean` repository must be applied **first**, so the
DNS contract object exists at the configured S3 path.

---

## File map

| File | What it does |
|---|---|
| `versions.tf` | OpenTofu version and provider constraints |
| `backend.tf` | S3 state backend (configured at `tofu init` time) |
| `providers.tf` | Cloudflare + AWS providers |
| `variables.tf` | All input variables with defaults and descriptions |
| `contract.tf` | Reads contract from S3 and decodes it with `jsondecode()` |
| `dns.tf` | Creates `cloudflare_dns_record` resources via `for_each` |
| `outputs.tf` | Exposed outputs |
| `example.tfvars` | Sample variable values for a new project |

---

## Bootstrap a new project

### 1. Clone or copy the repository

```bash
cp -r infra-cloudflare my-project-infra-cloudflare
cd my-project-infra-cloudflare
```

### 2. Set environment variables

```bash
export CLOUDFLARE_API_TOKEN="..."
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
```

When reading from **DigitalOcean Spaces**, use your Spaces access key
for the AWS credentials.

### 3. Create a tfvars file

```bash
cp example.tfvars prod.tfvars
```

Edit `prod.tfvars` and set at minimum:

```hcl
environment        = "prod"
cloudflare_zone_id = "abc123..."  # Cloudflare zone ID
contract_bucket    = "your-contracts-bucket"
contract_key       = "contracts/prod/digitalocean-dns-targets.json"
```

`contract_bucket` and `contract_key` must match the values used in
the `infra-digitalocean` repository so this repo reads the correct
contract object.

For DigitalOcean Spaces, uncomment and set the `s3_*` overrides:

```hcl
s3_endpoint                   = "https://nyc3.digitaloceanspaces.com"
s3_skip_credentials_validation = true
s3_skip_metadata_api_check     = true
s3_skip_requesting_account_id  = true
s3_force_path_style            = true
```

### 4. Initialize the backend

The backend key includes the repo prefix. Match the environment name:

**AWS S3:**
```bash
tofu init \
  -backend-config="bucket=your-state-bucket" \
  -backend-config="key=cloudflare/prod.tfstate" \
  -backend-config="region=us-east-1"
```

**DigitalOcean Spaces:**
```bash
tofu init \
  -backend-config="bucket=your-state-bucket" \
  -backend-config="key=cloudflare/prod.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="endpoint=https://nyc3.digitaloceanspaces.com" \
  -backend-config="skip_credentials_validation=true" \
  -backend-config="skip_metadata_api_check=true" \
  -backend-config="skip_requesting_account_id=true" \
  -backend-config="force_path_style=true"
```

### 5. Verify the contract is reachable

Before applying, confirm the contract object exists. The plan will
fail if the S3 object is missing.

### 6. Plan and apply

```bash
tofu plan   -var-file=prod.tfvars
tofu apply  -var-file=prod.tfvars
```

---

## Adding a new DNS record

**No code changes are needed in this repository.**

Records are created by `for_each` over the decoded contract. To add
a DNS record:

1. In `infra-digitalocean`, add the DigitalOcean resource (`main.tf`)
   and a corresponding entry in `local.dns_records` (`contract.tf`).
2. Apply `infra-digitalocean` to publish the updated contract.
3. Apply this repository. The `for_each` picks up the new record
   automatically — existing records are left untouched.

Example: after adding a `worker` record to the contract, the plan
shows one new `cloudflare_dns_record` being created, with zero changes
to the existing `app` and `api` records.

---

## Adding a new environment (e.g. staging)

```bash
# 1. Create a new tfvars file
cp example.tfvars staging.tfvars

# 2. Edit it — use staging-specific values
#    environment        = "staging"
#    cloudflare_zone_id = "zone-for-staging"
#    contract_key       = "contracts/staging/digitalocean-dns-targets.json"

# 3. Init a new backend state for staging
tofu init \
  -backend-config="bucket=your-state-bucket" \
  -backend-config="key=cloudflare/staging.tfstate" \
  -backend-config="region=us-east-1"

# 4. Plan and apply
tofu plan  -var-file=staging.tfvars
tofu apply -var-file=staging.tfvars
```

The staging Deployment must have its own contract object, produced by
a separate run of `infra-digitalocean` with `environment = "staging"`.

---

## Apply order

```
1. infra-digitalocean  ← runs first, publishes contract to S3
2. infra-cloudflare    ← this repo, reads contract from S3
```

In CI/CD, gate the Cloudflare pipeline on a successful DigitalOcean
pipeline run.

---

## Contract format

This repository expects the contract JSON at the configured S3 path
to have this schema:

```json
{
  "schema_version": 1,
  "environment": "prod",
  "records": {
    "frontend": {
      "name": "app",
      "type": "A",
      "content": "203.0.113.10",
      "proxied": true,
      "ttl": 1
    },
    "backend": {
      "name": "api",
      "type": "A",
      "content": "203.0.113.11",
      "proxied": true,
      "ttl": 1
    }
  }
}
```

Record fields passed through to the `cloudflare_dns_record` resource:
- `name` → DNS hostname (joined with the zone name)
- `type` → Record type (`A`, `AAAA`, `CNAME`, etc.)
- `content` → Target IP or hostname
- `proxied` → `true` for orange-cloud, `false` for grey-cloud
- `ttl` → Must be `1` when `proxied = true`

---

## Common commands

```bash
tofu init -backend-config="..."    # first time or after backend changes
tofu plan  -var-file=prod.tfvars   # preview changes
tofu apply -var-file=prod.tfvars   # apply changes
tofu destroy -var-file=prod.tfvars # tear down all DNS records
tofu output                        # show created DNS records
```
