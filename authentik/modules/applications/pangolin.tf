# Create an application with a provider attached and policies applied

data "authentik_flow" "default-authorization-flow" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_flow" "default-provider-invalidation-flow" {
  slug = "default-provider-invalidation-flow"
}
resource "authentik_provider_oauth2" "provider_for_pangolin" {
  name               = "Pangolin Provider"
  client_id          = "pangolin080012"
  allowed_redirect_uris = [
    {
      matching_mode = "strict",
      url           = "https://10.10.10.10:8006/oauth2/callback",
    }
  ]
  invalidation_flow = data.authentik_flow.default-provider-invalidation-flow.id
  authorization_flow = data.authentik_flow.default-authorization-flow.id
}

resource "authentik_application" "pangolin" {
  name              = "pangolin"
  slug              = "pangolin"
  protocol_provider = authentik_provider_oauth2.provider_for_pangolin.id
}