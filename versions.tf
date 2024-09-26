terraform {

  cloud {
    organization = "ncdl-org"

    workspaces {
      name = "d3-homelab"
    }
  }
}