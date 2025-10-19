module "applications" {
  source = "./modules/applications"
  AUTHENTIK_TOKEN = var.AUTHENTIK_TOKEN
  AUTHENTIK_URL = var.AUTHENTIK_URL
}