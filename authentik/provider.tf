terraform {
  required_providers {
    authentik = {
      source = "goauthentik/authentik"
      version = "2025.8.1"
    }
  }
}

provider "authentik" {
  url   = "https://auth.d3adc3ii.cc"
  token = var.AUTHENTIK_TOKEN
  #insecure = true
  # Optionally add extra headers
  # headers {
  #   X-my-header = "foo"
  # }
  #  Set token with `export AUTHENTIK_TOKEN='<your-token>'`
}
