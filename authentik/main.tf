module "proxmox" {
  source = "./modules/applications/proxmox"
  AUTHENTIK_TOKEN = var.AUTHENTIK_TOKEN
  AUTHENTIK_URL = var.AUTHENTIK_URL
}
module "komodo" {
  source = "./modules/applications/komodo"
  AUTHENTIK_TOKEN = var.AUTHENTIK_TOKEN
  AUTHENTIK_URL = var.AUTHENTIK_URL
}
module "beszel" {
  source = "./modules/applications/beszel"
  AUTHENTIK_TOKEN = var.AUTHENTIK_TOKEN
  AUTHENTIK_URL = var.AUTHENTIK_URL
}
module "pangolin" {
  source = "./modules/applications/pangolin"
  AUTHENTIK_TOKEN = var.AUTHENTIK_TOKEN
  AUTHENTIK_URL = var.AUTHENTIK_URL
}
module "passwordless-flow" {
  source = "./modules/flows/passwordless"
  AUTHENTIK_TOKEN = var.AUTHENTIK_TOKEN
  AUTHENTIK_URL = var.AUTHENTIK_URL
}