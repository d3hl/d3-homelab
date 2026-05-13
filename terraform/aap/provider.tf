terraform {
  required_version = ">= 1.5.0"

  cloud {
    organization = "d3-org"
    workspaces {
      project = "homelab"
      name    = "aap"
    }
  }

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.104"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 2.1"
    }
  }
}

# Authenticates via OP_SERVICE_ACCOUNT_TOKEN environment variable.
# Set this as a sensitive workspace env var in HCP Terraform — never in .tfvars.
provider "onepassword" {
  service_account_token = var.OP_SERVICE_ACCOUNT_TOKEN
}

provider "proxmox" {
  endpoint  = data.onepassword_item.proxmox.url
  api_token = data.onepassword_item.proxmox.password
  insecure  = true

  ssh {
    agent    = true
    username = "d3"

    node {
      name    = "nodeA"
      address = "10.10.10.18"
    }
    node {
      name    = "nodeB"
      address = "10.10.10.15"
    }
    node {
      name    = "nodeD"
      address = "10.10.10.17"
    }
    node {
      name    = "nodeF"
      address = "10.10.10.10"
    }
  }
}
