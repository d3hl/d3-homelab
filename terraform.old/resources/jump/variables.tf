variable "virtual_environment_endpoint" {
  type = string
}

variable "virtual_environment_username" {
  description = "Proxmox User for API Access"
  type        = string
}

variable "vm_hostname" {
  type    = string
  default = " proxmox_virtual_environment_vm.kmd1.ipv4_addresses[1][0]"
}
variable "hostname" {
  type    = string
  default = "omni-master1"
}

variable "virtual_environment_api_token" {
  description = "The API token for the Proxmox Virtual Environment API"
  type        = string
  sensitive   = true
}

variable "virtual_environment_node_name" {
  description = "Name of the Proxmox node"
  type        = string
  default     = "nodeA"
}
variable "datastore_id" {
  description = "ID of the Proxmox datastore"
  type        = string
  default     = "cephVM"
}
variable "filestore_id" {
  description = "ID of the Proxmox datastore"
  type        = string
  default     = "cFS"
}