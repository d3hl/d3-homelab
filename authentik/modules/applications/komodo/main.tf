# Create an application with a provider attached and policies applied

data "authentik_flow" "default-authorization-flow" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_flow" "default-provider-invalidation-flow" {
  slug = "default-provider-invalidation-flow"
}
resource "authentik_provider_oauth2" "provider_for_komodo" {
  name               = "Komodo Provider"
  client_id          = "komodo080012"
  allowed_redirect_uris = [
    {
      matching_mode = "strict",
      url           = "http://10.10.10.30:9120/auth/oidc/callback",
    }
  ]
  invalidation_flow = data.authentik_flow.default-provider-invalidation-flow.id
  authorization_flow = data.authentik_flow.default-authorization-flow.id
}

resource "authentik_application" "komodo" {
  name              = "komodo"
  slug              = "komodo"
  protocol_provider = authentik_provider_oauth2.provider_for_komodo.id
}