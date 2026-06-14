variable "environment" {
  description = "Deployment environment name (e.g. prod, staging)"
  type        = string
  default     = "prod"
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for the DNS zone to manage"
  type        = string
}

variable "contract_bucket" {
  description = "S3 bucket name that holds the DNS contract object"
  type        = string
}

variable "contract_key" {
  description = "S3 object key (path) for the DNS contract"
  type        = string
}

# ── S3-compatible storage provider configuration ──

variable "contract_storage_region" {
  description = "AWS region for the S3-compatible contract storage"
  type        = string
  default     = "us-east-1"
}

variable "s3_endpoint" {
  description = "S3-compatible endpoint URL (leave empty for standard AWS S3)"
  type        = string
  default     = null
}

variable "s3_skip_credentials_validation" {
  description = "Skip AWS credential validation (required for S3-compatible storage)"
  type        = bool
  default     = false
}

variable "s3_skip_metadata_api_check" {
  description = "Skip AWS metadata API check (required for S3-compatible storage)"
  type        = bool
  default     = false
}

variable "s3_skip_requesting_account_id" {
  description = "Skip requesting AWS account ID (required for S3-compatible storage)"
  type        = bool
  default     = false
}

variable "s3_force_path_style" {
  description = "Force path-style addressing (required for S3-compatible storage)"
  type        = bool
  default     = false
}
