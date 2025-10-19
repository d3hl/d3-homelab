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
}
