# Include all settings from the root Terragrunt configuration file
include {
  path = find_in_parent_folders("root.hcl")
  merge_strategy = "deep"
}

locals {
  env     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  identifier = local.env.locals.env_name
  tags = merge(local.env.locals.environment_tags, local.proj.locals.project_tags)

  apps = {
    # Example of an application
      argocd = {
        domain            = "argocd-${local.identifier}.domain.com"
        create_dns_record = true
        access_groups_id  = "access-groups-id"
        session_duration  = "24h"
        service_auth_401_redirect = true
        service = "http://argocd-server.argocd.svc.cluster.local:80"
      }
  }
}


terraform {
  source = "git::ssh://git@github.com/lumiaops/cloudflare-ztn.git?ref=main"
}

inputs = {
  cloudflare_token_secret_arn = "cloudflare-token"
  cloudflare_account_id = "loudflare-account-id"
  zone_id               = "zone-id"
  tunnel_name           = local.identifier  
  applications          = local.apps
  domain                = "domain.com"
  team_name             = "team-name"
  tags = local.tags
  identifier = local.identifier
}

