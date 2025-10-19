# Create an application with a provider attached and policies applied

data "authentik_flow" "default-authorization-flow" {
  slug = "default-provider-authorization-implicit-consent"
}
resource "authentik_provider_oauth2" "provider_for_proxmox" {
  name               = "proxmox"
  client_id          = "example-app"
  client_secret      = "test"
  authorization_flow = data.authentik_flow.default-authorization-flow.id
}

resource "authentik_application" "proxmox" {
  name              = "proxmox"
  slug              = "proxmox"
  protocol_provider = authentik_provider_oauth2.provider_for_proxmox.id
}