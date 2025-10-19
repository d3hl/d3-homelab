# Create an application with a provider attached and policies applied

data "authentik_flow" "default-authorization-flow" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_flow" "default-provider-invalidation-flow" {
  slug = "default-provider-invalidation-flow"
}
resource "authentik_provider_oauth2" "provider_for_immich" {
  name               = "Immich Provider"
  client_id          = "immich080012"
  allowed_redirect_uris = [
    {
      matching_mode = "strict",
      url           = "https://10.10.10.10:8006/oauth2/callback",
    }
  ]
  invalidation_flow = data.authentik_flow.default-provider-invalidation-flow.id
  authorization_flow = data.authentik_flow.default-authorization-flow.id
}

resource "authentik_application" "immich" {
  name              = "immich"
  slug              = "immich"
  protocol_provider = authentik_provider_oauth2.provider_for_immich.id
}