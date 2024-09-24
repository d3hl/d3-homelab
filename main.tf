#locals {
#    name_suffix = "${var.resource_tags["projects"]}-${var.resource_tags["environment"]}"
#}


module "dok-hl-39" {
  source = "./prod/dok-hl-39"
}