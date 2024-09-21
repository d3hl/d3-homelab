terraform {

  cloud {
    organization ="ncdv-org"

    workspaces {
      name = "d3-homelab"
    }
  }
}