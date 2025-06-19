# Cloudflare ZTNA Tunnel

<div align="center">

![Zero Trust](https://img.shields.io/badge/Zero--Trust-Cloudflare-orange?style=for-the-badge&logo=cloudflare&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-Infrastructure-623CE4?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-Secrets-FF9900?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Security](https://img.shields.io/badge/Security-Zero--Trust-red?style=for-the-badge&logo=security&logoColor=white)

</div>

<div align="center">
  <img src="https://cf-assets.www.cloudflare.com/slt3lc6tev37/5Cr0cOWVoVXoiyaiaKUJro/62be0746986138e0774a4b8a7522b04a/security-week-hero.svg" alt="Cloudflare Zero Trust" width="800"/>
</div>

---

## 🏗️ Architecture

This Terraform module provisions and manages a **Cloudflare Zero Trust Tunnel** and related resources for secure, authenticated access to internal applications. It is designed for use within a larger Infrastructure as Code (IaC) setup, providing enterprise-grade security through Zero Trust principles.

### 🔐 **Zero Trust Components**
- **Cloudflare Tunnel**: Secure outbound-only connections to your infrastructure
- **Access Applications**: Application-level security policies
- **Access Policies**: Fine-grained access control with MFA support
- **DNS Management**: Automated DNS record creation
- **Token Security**: Secure storage in AWS Secrets Manager

### 🌐 **Security Features**
- ✅ **Zero Trust Architecture**: Never trust, always verify
- ✅ **Multi-Factor Authentication**: Enhanced security for sensitive applications
- ✅ **Identity-Based Access**: Email and group-based authentication
- ✅ **Session Management**: Configurable session durations
- ✅ **DNS Automation**: Seamless domain management

## 🚀 Quick Start

### Prerequisites

- **Terraform** >= 1.0
- **Cloudflare Account** with Zero Trust enabled
- **AWS Account** for secrets storage
- Valid **DNS Zone** in Cloudflare

### 🛠️ Basic Usage

```hcl
module "cloudflare_tunnel" {
  source                = "./cloudflare-ztn_tf"
  cloudflare_account_id = var.cloudflare_account_id
  zone_id              = var.cloudflare_zone_id
  domain               = "example.com"
  identifier           = "prod"
  team_name            = "devops"
  aws_region           = "us-west-2"
  
  tags = {
    Environment = "production"
    Project     = "secure-access"
    Team        = "infrastructure"
  }
  
  applications = {
    "web-app" = {
      domain            = "app.example.com"
      service           = "http://10.0.0.1:8080"
      access_groups     = ["admin-group"]
      require_mfa       = true
      create_dns_record = true
      session_duration  = "8h"
    },
    "api-service" = {
      domain            = "api.example.com"
      service           = "http://10.0.0.2:3000"
      allowed_emails    = ["admin@example.com", "dev@example.com"]
      require_mfa       = true
      create_dns_record = true
      session_duration  = "24h"
    },
    "dashboard" = {
      domain            = "dashboard.example.com"
      service           = "https://10.0.0.3:8443"
      allowed_groups    = ["engineers", "managers"]
      require_mfa       = false
      create_dns_record = true
      session_duration  = "4h"
    }
  }
}
```

## ⚙️ Configuration

### 📋 Input Variables

| Name                   | Type     | Description                                      | Required | Default |
|------------------------|----------|--------------------------------------------------|----------|---------|
| `cloudflare_account_id`| string   | Cloudflare account ID                            | ✅       | -       |
| `applications`         | map      | Map of application configurations                | ✅       | -       |
| `zone_id`              | string   | Cloudflare DNS zone ID                           | ✅       | -       |
| `tags`                 | map      | Tags to apply to resources                       | ✅       | -       |
| `identifier`           | string   | Environment identifier (dev/staging/prod)        | ✅       | -       |
| `domain`               | string   | Domain of the Cloudflare zone                    | ✅       | -       |
| `aws_region`           | string   | AWS region for secrets storage                   | ✅       | -       |
| `team_name`            | string   | Name of the team                                 | ✅       | -       |

### 🔧 Application Configuration

Each entry in `applications` supports the following attributes:

```hcl
{
  domain            = "app.example.com"     # Required: FQDN for the application
  service           = "http://10.0.0.1:80"  # Required: Backend service URL
  access_groups     = ["group1", "group2"]  # Optional: Cloudflare Access groups
  allowed_emails    = ["user@example.com"]  # Optional: Allowed email addresses
  allowed_groups    = ["team-a", "team-b"]  # Optional: Allowed groups
  session_duration  = "8h"                  # Optional: Session duration (default: 1h)
  require_mfa       = true                  # Optional: Require MFA (default: true)
  create_dns_record = true                  # Optional: Create DNS CNAME (default: false)
}
```

### 📤 Outputs

| Name                  | Description                                    |
|-----------------------|------------------------------------------------|
| `tunnel_id`           | ID of the created Cloudflare tunnel           |
| `tunnel_token_secret` | ARN of AWS secret containing the tunnel token |
| `application_domains` | List of configured application domains         |
| `dns_records`         | Created DNS record information                 |

## 🔐 Security Features

### 🛡️ **Zero Trust Principles**
- **Identity Verification**: Every request is authenticated and authorized
- **Least Privilege Access**: Minimal required permissions for each application
- **Continuous Monitoring**: Real-time security posture assessment

### 🔑 **Authentication Methods**
- **Multi-Factor Authentication (MFA)**: Hardware keys, TOTP, SMS
- **Email-Based Access**: Whitelist specific email addresses
- **Group-Based Access**: Integration with identity providers
- **Session Management**: Configurable timeout periods

### 🔒 **Data Protection**
- **Encrypted Tunnels**: All traffic encrypted in transit
- **Token Security**: Tunnel tokens stored in AWS Secrets Manager
- **Certificate Management**: Automatic SSL/TLS certificate provisioning

## 🏗️ Resources Created

### Cloudflare Resources
- ✅ **Zero Trust Tunnel**: Secure connection endpoint
- ✅ **Tunnel Configuration**: Per-application routing rules
- ✅ **Access Applications**: Application security policies
- ✅ **Access Policies**: Fine-grained access controls
- ✅ **DNS Records**: Automated domain management (optional)

### AWS Resources
- ✅ **Secrets Manager Secret**: Encrypted tunnel token storage
- ✅ **Secret Version**: Secure token versioning

## 🚀 Deployment

### 1. **Initialize Terraform**
```bash
terraform init
```

### 2. **Plan Deployment**
```bash
terraform plan -var-file="terraform.tfvars"
```

### 3. **Apply Configuration**
```bash
terraform apply -var-file="terraform.tfvars"
```

### 4. **Verify Tunnel**
```bash
# Check tunnel status in Cloudflare Zero Trust dashboard
# Test application access through configured domains
```

## 🔧 Advanced Configuration

### Custom Access Policies

```hcl
applications = {
  "secure-app" = {
    domain         = "secure.example.com"
    service        = "http://10.0.0.1:8080"
    access_groups  = ["security-team"]
    require_mfa    = true
    
    # Custom policy configurations
    session_duration = "2h"
    
    # Additional security settings
    allowed_countries = ["US", "CA"]
    require_fresh_login = true
  }
}
```

### Multiple Environment Support

```hcl
# Development Environment
module "dev_tunnel" {
  source     = "./cloudflare-ztn_tf"
  identifier = "dev"
  domain     = "dev.example.com"
  # ... other configurations
}

# Production Environment  
module "prod_tunnel" {
  source     = "./cloudflare-ztn_tf"
  identifier = "prod"
  domain     = "prod.example.com"
  # ... other configurations
}
```

## 🔍 Monitoring & Troubleshooting

### 📊 **Monitoring**
- **Cloudflare Analytics**: Traffic and security insights
- **Access Logs**: Authentication and authorization events
- **Tunnel Health**: Connection status and performance metrics

### 🚨 **Common Issues**

#### Tunnel Connectivity
```bash
# Check tunnel status
cloudflared tunnel list

# Test local service connectivity
curl -I http://localhost:8080

# Verify DNS resolution
nslookup app.example.com
```

#### Access Policy Issues
1. **403 Forbidden**: Check access group membership
2. **Redirect Loops**: Verify application configuration
3. **SSL Errors**: Ensure proper certificate configuration

#### AWS Secrets Manager
```bash
# Retrieve tunnel token
aws secretsmanager get-secret-value \
  --secret-id cloudflare-tunnel-token-prod \
  --region us-west-2
```

### 🛠️ **Debug Commands**

```bash
# Check Terraform state
terraform state list
terraform state show module.cloudflare_tunnel.cloudflare_tunnel.main

# Validate Cloudflare configuration
terraform validate
terraform plan -detailed-exitcode

# Test tunnel connectivity
cloudflared tunnel --config /etc/cloudflared/config.yml run
```

## 📚 Documentation

### 🔗 **Official Resources**
- [Cloudflare Zero Trust Documentation](https://developers.cloudflare.com/cloudflare-one/)
- [Cloudflare Tunnel Documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)
- [Cloudflare Access Documentation](https://developers.cloudflare.com/cloudflare-one/applications/)
- [AWS Secrets Manager Documentation](https://docs.aws.amazon.com/secretsmanager/)

### 🧰 **Tools & CLI**
- [Cloudflared CLI](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/)
- [Terraform Cloudflare Provider](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs)
- [AWS CLI](https://aws.amazon.com/cli/)

### 📖 **Best Practices**
- [Zero Trust Security Model](https://www.cloudflare.com/learning/security/glossary/what-is-zero-trust/)
- [Infrastructure as Code with Terraform](https://www.terraform.io/use-cases/infrastructure-as-code)
- [Multi-Factor Authentication Setup](https://developers.cloudflare.com/cloudflare-one/identity/one-time-pin/)
