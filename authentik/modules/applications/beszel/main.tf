# Create an application with a provider attached and policies applied
data "authentik_group" "d3-admins" {
  name = "d3-admins"
}

data "authentik_flow" "default-authorization-flow" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_flow" "default-provider-invalidation-flow" {
  slug = "default-provider-invalidation-flow"
}
resource "authentik_provider_oauth2" "provider_for_beszel" {
  name               = "Beszel Provider"
  client_id          = "beszel080012"
  allowed_redirect_uris = [
    {
      matching_mode = "strict",
      url           = "https://beszel.d3adc3ii.cc/api/oauth2-redirect"
    }
  ]
  invalidation_flow = data.authentik_flow.default-provider-invalidation-flow.id
  authorization_flow = data.authentik_flow.default-authorization-flow.id
}

resource "authentik_application" "beszel" {
  name              = "beszel"
  slug              = "beszel"
  protocol_provider = authentik_provider_oauth2.provider_for_beszel.id
  group            = data.authentik_group.d3-admins.id
}

# Binding policy to application to allow access to specific group
resource "authentik_policy_binding" "app-access" {
  target = authentik_application.beszel.uuid
  group  = data.authentik_group.d3-admins.id
  order  = 0
}