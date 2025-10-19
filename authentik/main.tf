module "proxmox" {
  source = "./modules/applications"
  AUTHENTIK_TOKEN = var.AUTHENTIK_TOKEN
  AUTHENTIK_URL = var.AUTHENTIK_URL
}
module "immich" {
  source = "./modules/applications"
  AUTHENTIK_TOKEN = var.AUTHENTIK_TOKEN
  AUTHENTIK_URL = var.AUTHENTIK_URL
}
module "beszel" {
  source = "./modules/applications"
  AUTHENTIK_TOKEN = var.AUTHENTIK_TOKEN
  AUTHENTIK_URL = var.AUTHENTIK_URL
}