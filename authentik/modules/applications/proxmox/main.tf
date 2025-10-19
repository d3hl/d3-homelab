# Create an application with a provider attached and policies applied

data "authentik_flow" "default-authorization-flow" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_flow" "default-provider-invalidation-flow" {
  slug = "default-provider-invalidation-flow"
}
resource "authentik_provider_oauth2" "provider_for_proxmox" {
  name               = "Proxmox Provider"
  client_id          = "proxmox"
  allowed_redirect_uris = [
    {
      matching_mode = "strict",
      url           = "https://komodo.d3adc3ii.cc/auth/oidc/callback",

    }
  ]
  invalidation_flow = data.authentik_flow.default-provider-invalidation-flow.id
  authorization_flow = data.authentik_flow.default-authorization-flow.id
}

resource "authentik_application" "proxmox" {
  name              = "proxmox"
  slug              = "proxmox"
  protocol_provider = authentik_provider_oauth2.provider_for_proxmox.id
}