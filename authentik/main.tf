module "application_entitle" {
  source = "./modules/application_entitle"
  AUTHENTIK_TOKEN = var.AUTHENTIK_TOKEN 
  AUTHENTIK_URL   = var.AUTHENTIK_URL 

}
