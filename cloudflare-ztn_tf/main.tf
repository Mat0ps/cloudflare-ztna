# Get Cloudflare API Token from AWS Secrets Manager
data "aws_secretsmanager_secret_version" "cloudflare_api_token" {
  secret_id = var.cloudflare_token_secret_arn
}

provider "cloudflare" {
  api_token = jsondecode(data.aws_secretsmanager_secret_version.cloudflare_api_token.secret_string).api_token
}

# Cloudflare Zone
data "cloudflare_zone" "this" {
  zone_id = var.zone_id
}

# Tunnel Secret Generation
resource "random_password" "tunnel_secret" {
  length  = 64
  special = false
}

# Single Zero Trust Tunnel for all applications
resource "cloudflare_zero_trust_tunnel_cloudflared" "tunnel_cloudflared" {
  account_id    = var.cloudflare_account_id
  name          = "${var.identifier}-tunnel"
  config_src    = "cloudflare"
  tunnel_secret = base64encode(random_password.tunnel_secret.result)
}

# Tunnel Token
data "cloudflare_zero_trust_tunnel_cloudflared_token" "tunnel_cloudflared_token" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.tunnel_cloudflared.id
}

# Delete existing secret if it exists
resource "null_resource" "delete_existing_secret" {
  provisioner "local-exec" {
    command = "aws secretsmanager delete-secret --secret-id \"${var.identifier}/cloudflare-tunnel-token-*\" --force-delete-without-recovery --region ${var.aws_region} || true"
  }
}

# Store Cloudflare Tunnel Token in AWS Secrets Manager
resource "aws_secretsmanager_secret" "cloudflare_tunnel_token" {
  name        = "${var.identifier}/cloudflare-tunnel-token"
  description = "Cloudflare Zero Trust Tunnel Token for ${var.identifier}"
  tags        = var.tags
  recovery_window_in_days = 0
  
  depends_on = [null_resource.delete_existing_secret]
}

resource "aws_secretsmanager_secret_version" "cloudflare_tunnel_token" {
  secret_id     = aws_secretsmanager_secret.cloudflare_tunnel_token.id
  secret_string = data.cloudflare_zero_trust_tunnel_cloudflared_token.tunnel_cloudflared_token.token
}

# Single Tunnel Configuration with all applications
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "tunnel_cloudflared_config" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.tunnel_cloudflared.id
  
  config = {
    ingress = concat(
      [
        for app_key, app in var.applications : {
          hostname = app.domain
          service  = app.service
        }
      ],
      [
        {
          service = "http_status:404"
        }
      ]
    )
  }
}

# Access Applications (per app)
resource "cloudflare_zero_trust_access_application" "access_application" {
  for_each = var.applications
  account_id       = var.cloudflare_account_id
  name             = "${each.key}-${var.identifier}"
  domain           = each.value.domain
  type             = "self_hosted"
  session_duration = each.value.session_duration
  
  # Link access policies to this application
  policies = [
    {
      id = cloudflare_zero_trust_access_policy.access_policy.id
      precedence = 1
    }
  ]
}

# DNS Records (per app)
resource "cloudflare_dns_record" "dns_record" {
  for_each = var.applications
  zone_id = var.zone_id
  name    = trimsuffix(each.value.domain, ".${var.domain}")
  type    = "CNAME"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.tunnel_cloudflared.id}.cfargotunnel.com"
  ttl     = 1
  proxied = true
}

resource "cloudflare_zero_trust_access_policy" "access_policy" {
  account_id       = var.cloudflare_account_id
  name             = "${var.identifier}-policy"
  decision         = "allow"
  session_duration = "24h"

  include = [{
    email_domain = {
      domain = "lumia.security"  
    }
  }]
}
