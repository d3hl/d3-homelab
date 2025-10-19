### Look up for existing groups and flows ###
data "authentik_group" "homelab-admins" {
  name = "homelab-admins"
}

data "authentik_flow" "default-authorization-flow" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_flow" "default-provider-invalidation-flow" {
  slug = "default-provider-invalidation-flow"
}



#### Create resource for Pangolin OAuth2 provider ###

resource "authentik_provider_oauth2" "provider_for_pangolin" {
  name               = "Pangolin Provider"
  client_id          = "pangolin080012"
  allowed_redirect_uris = [
    {
      matching_mode = "strict",
      url           = "https://pangolin.d3adc3ii.cc/auth/idp/2/oidc/callback",
    }
  ]
  invalidation_flow = data.authentik_flow.default-provider-invalidation-flow.id
  authorization_flow = data.authentik_flow.default-authorization-flow.id
}

resource "authentik_application" "pangolin" {
  name              = "pangolin"
  slug              = "pangolin"
  protocol_provider = authentik_provider_oauth2.provider_for_pangolin.id
  group            = data.authentik_group.homelab-admins.id
}