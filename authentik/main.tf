# Create an application with a provider attached and policies applied

data "authentik_flow" "default-authorization-flow" {
  slug = "default-provider-authorization-implicit-consent"
}
resource "authentik_provider_oauth2" "provider_for_proxmox" {
  name               = "Proxmox Provider"
  client_id          = "proxmox"
  client_secret      = "test"
  allowed_redirect_uris = [
    {
      matching_mode = "strict",
      url           = "https://10.10.10.10:8006/oauth2/callback",
    }
  ]

  authorization_flow = data.authentik_flow.default-authorization-flow.id
}

resource "authentik_application" "proxmox" {
  name              = "proxmox"
  slug              = "proxmox"
  protocol_provider = authentik_provider_oauth2.provider_for_proxmox.id
}