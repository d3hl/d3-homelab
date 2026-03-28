variable "virtual_environment_endpoint" {
  type = string
}

variable "virtual_environment_api_token" {
  description = "The API token for the Proxmox Virtual Environment API"
  type        = string
  sensitive   = true
}


variable "virtual_environment_node_name" {
  description = "Name of the Proxmox node"
  type        = string
  default     = "nodeD"
}
variable "virtual_environment_node_pve10" {
  description = "Name of the Proxmox node"
  type        = string
  default     = "pve10"
}
variable "datastore_id" {
  type        = string
  description = "Datastore for VM disks"
  default     = "cephVM"
}
variable "ubuntu_template" {
  type    = string
  default = "999"
}
