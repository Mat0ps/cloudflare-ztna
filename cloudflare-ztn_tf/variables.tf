variable "cloudflare_token_secret_arn" {
  type        = string
  description = "Cloudflare API token secret ARN"
}

variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare account ID"
}

variable "applications" {
  type = map(object({
    domain            = string
    service           = string
    access_groups     = optional(list(string), [])
    session_duration  = optional(string, "1h")
    require_mfa       = optional(bool, true)
    create_dns_record = optional(bool, false)
  }))
  description = "Zero Trust applications and their tunnel targets"
}

variable "zone_id" {
  type        = string
  description = "Cloudflare DNS zone ID for CNAME records"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the resources"
}

variable "identifier" {
  type        = string
  description = "The identifier of the environment"
}

variable "domain" {
  type        = string
  description = "The domain of the Cloudflare zone"
}

variable "aws_region" {
  type        = string
  description = "AWS region to store secrets"
}

variable "team_name" {
  type        = string
  description = "The name of the team"
}
