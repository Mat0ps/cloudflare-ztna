output "tunnel_token" {
  value     = data.cloudflare_zero_trust_tunnel_cloudflared_token.tunnel_cloudflared_token.token
  sensitive = true
}

output "tunnel_id" {
  value = cloudflare_zero_trust_tunnel_cloudflared.tunnel_cloudflared.id
}

output "tunnel_secret" {
  value     = cloudflare_zero_trust_tunnel_cloudflared.tunnel_cloudflared.tunnel_secret
  sensitive = true
}


