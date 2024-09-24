#locals {
#    name_suffix = "${var.resource_tags["projects"]}-${var.resource_tags["environment"]}"
#}


module "dok-hl-19" {
  source = "./prod/dok-hl-19"
}