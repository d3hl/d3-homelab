variable "virtual_environment_endpoint" {
  description = "The endpoint for the Proxmox Virtual Environment API (example: https://host:port)"
  type        = string
}

variable "virtual_environment_username" {
  description = "Proxmox User for API Access"
  type        = string
  default     = "root@pam"
}

#variable "virtual_environment_password" {
#  description = "Password for Proxmox API User"
#  type        = string
#  sensitive   = true
#  default     = "don not use default passwords!"
#}

variable "virtual_environment_api_token" {
  description = "The API token for the Proxmox Virtual Environment API"
  type        = string
  sensitive   = true
}



variable "virtual_environment_node_name" {
  description = "Name of the Proxmox node"
  type        = string
  default     = "pve10"
}
variable "datastore_id" {
  type        = string
  description = "Datastore for VM disks"
  default     = "cephfs"
}
variable "ssh_public_key)" {
  type = string
}