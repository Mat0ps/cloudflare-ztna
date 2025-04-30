# Cloudflare Zero Trust Tunnel Terraform Module

This module provisions and manages a Cloudflare Zero Trust Tunnel and related resources for secure, authenticated access to internal applications. It is designed for use within a larger Infrastructure as Code (IaC) setup, such as the one described in the root repository README.

## Features
- Creates a single Cloudflare Zero Trust Tunnel
- Configures per-application ingress rules
- Sets up Cloudflare Access Applications and Policies
- Optionally creates DNS records for applications
- Stores tunnel tokens securely in AWS Secrets Manager

## Usage

```hcl
module "cloudflare_tunnel" {
  source              = "path/to/modules/cloudflare-ztn_tf"
  cloudflare_account_id = var.cloudflare_account_id
  zone_id             = var.cloudflare_zone_id
  domain              = "example.com"
  identifier          = "prod"
  team_name           = "devops"
  aws_region          = "us-west-2"
  tags                = {
    Environment = "production"
    Project     = "secure-access"
  }
  
  applications = {
    "app1" = {
      domain           = "app1.example.com"
      service          = "http://10.0.0.1:8080"
      access_groups    = ["admin-group"]
      require_mfa      = true
      create_dns_record = true
    },
    "app2" = {
      domain           = "app2.example.com"
      service          = "http://10.0.0.2:3000"
      allowed_emails   = ["user@example.com"]
      session_duration = "24h"
      create_dns_record = true
    }
  }
}
```

## Input Variables
| Name                   | Type     | Description                                      | Required | Default |
|------------------------|----------|--------------------------------------------------|----------|---------|
| cloudflare_account_id  | string   | Cloudflare account ID                            | yes      | -       |
| applications           | map      | Map of application configs (see below)           | yes      | -       |
| zone_id                | string   | Cloudflare DNS zone ID                           | yes      | -       |
| tags                   | map      | Tags to apply to resources                       | yes      | -       |
| identifier             | string   | Environment identifier                           | yes      | -       |
| domain                 | string   | Domain of the Cloudflare zone                    | yes      | -       |
| aws_region             | string   | AWS region for secrets storage                   | yes      | -       |
| team_name              | string   | Name of the team                                 | yes      | -       |

### Application Object
Each entry in `applications` should be an object with the following attributes:
- `domain` (string, required): The FQDN for the app
- `service` (string, required): The local service address (e.g., `http://10.0.0.1:8080`)
- `access_groups` (list(string), optional): Allowed Cloudflare Access groups
- `session_duration` (string, optional): Session duration (default: `1h`)
- `allowed_emails` (list(string), optional): Allowed emails
- `allowed_groups` (list(string), optional): Allowed groups
- `require_mfa` (bool, optional): Require MFA (default: `true`)
- `create_dns_record` (bool, optional): Create DNS CNAME (default: `false`)

## Outputs
| Name                | Description                                 |
|---------------------|---------------------------------------------|
| tunnel_id           | The ID of the created Cloudflare tunnel     |
| tunnel_token_secret | ARN of the secret containing tunnel token   |

## Resources Created
- Cloudflare Zero Trust Tunnel
- Cloudflare Zero Trust Tunnel Config (per app)
- Cloudflare Access Application (per app)
- Cloudflare Access Policy (per app)
- Cloudflare DNS Record (per app, optional)
- AWS Secrets Manager secret version for tunnel token

## Requirements
- Terraform >= 1.0
- Cloudflare provider >= 3.0
- AWS provider >= 4.0

## Deployment Instructions
1. Ensure you have the required provider credentials configured
2. Include this module in your Terraform configuration
3. Run `terraform init` to initialize the providers
4. Run `terraform plan` to preview the changes
5. Run `terraform apply` to deploy the infrastructure

## Security Considerations
- The tunnel token is stored in AWS Secrets Manager with encryption
- Access policies should be configured with least privilege in mind
- Enable MFA for sensitive applications

## Troubleshooting
If you encounter issues with tunnel connectivity:
- Verify your Cloudflare account has Zero Trust enabled
- Check that the tunnel daemon is running correctly
- Ensure firewall rules allow outbound connections to Cloudflare
- Verify that the local services are accessible at the specified addresses
