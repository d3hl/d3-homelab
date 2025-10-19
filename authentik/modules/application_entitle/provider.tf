terraform {
  required_providers {
    authentik = {
      source = "goauthentik/authentik"
      version = "2025.8.1"
    }
  }
}

provider "authentik" {
  AUTHENTIK_URL   = var.AUTHENTIK_URL
  AUTHENTIK_TOKEN = var.AUTHENTIK_TOKEN
}
