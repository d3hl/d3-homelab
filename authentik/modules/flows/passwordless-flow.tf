
# Create a WebAuthn setup stage

resource "authentik_stage_authenticator_webauthn" "d3-webauthn-setup" {
  name = "d3-webauthn-setup"
}

# Authentication stage
resource "authentik_flow" "d3-passwordless-flow" {
  name        = "d3-passwordless-flow"
  title       = "d3-Passwordless flow"
  slug        = "d3-passwordless-flow"
  designation = "authentication"
}
# Authentcator validation stage

# Create an Authenticator validations tage

resource "authentik_stage_authenticator_validate" "d3-webauthn-stage" {
  name                  = "d3 WebAuthn Validation Stage"
  flow                  = authentik_flow.d3-passwordless-flow.id
  device_classes        = ["WebAuthn"]
  not_configured_action = "configure"
  configuration_stages = [
    authentik_stage_authenticator_webauthn.d3-passwordless-setup.id,
  ]
}

resource "authentik_flow_stage_binding" "d3-bind-webauthn-to-flow" {
  target_flow = authentik_flow.d3-passwordless-flow.uuid
  stage  = authentik_stage_authenticator_webauthn.d3-webauthn-setup.id
  order  = 10
}

