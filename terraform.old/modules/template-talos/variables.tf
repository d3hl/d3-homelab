variable "virtual_environment_node_name" {
  description = "The Proxmox VE node name where the VM will be created."
  type        = string
  default     = "nodeA"

}

variable "datastore_id" {
  type        = string
  description = "Datastore for VM disks"
  default     = "cephVM"
}
variable "virtual_environment_endpoint" {
  type = string
}

variable "virtual_environment_username" {
  description = "Proxmox User for API Access"
  type        = string
}


variable "virtual_environment_api_token" {
  description = "The API token for the Proxmox Virtual Environment API"
  type        = string
  sensitive   = true
}
variable "os" {
  description = "Operating system for the template"
  type        = string
  default     = "ubuntu-talos"

}



