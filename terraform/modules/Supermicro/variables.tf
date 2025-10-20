variable "debian_cloud_image_file_id" {
  description = "File id of the Debian cloud image to use for VM disks. Typically passed from module.komodo.debian_cloud_image_file_id"
  type        = string
}
variable "virtual_environment_endpoint" {
  type        = string
}

variable "virtual_environment_username" {
  description = "Proxmox User for API Access"
  type        = string
}

#variable "virtual_environment_password" {
#  description = "Password for Proxmox API User"
#  type        = string
#  sensitive   = true
#  default     = "don not use default passwords!"
#}  #

variable "virtual_environment_api_token" {
  description = "The API token for the Proxmox Virtual Environment API"
  type        = string
  sensitive   = true
}

variable "virtual_environment_pve10_name" {
  description = "Name of the Proxmox node"
  type        = string
  default     = "pve10"
}
variable "virtual_environment_pve14_name" {
  description = "Name of the Proxmox node"
  type        = string
  default     = "pve14"
}
variable "virtual_environment_nodeA_name" {
  description = "Name of the Proxmox node"
  type        = string
  default     = "nodeA"
}
variable "virtual_environment_nodeB_name" {
  description = "Name of the Proxmox node"
  type        = string
  default     = "nodeB"
}
variable "virtual_environment_nodeC_name" {
  description = "Name of the Proxmox node"
  type        = string
  default     = "nodeC"
}
variable "datastore_id" {
  type        = string
  description = "Datastore for VM disks"
  default     = "cephVM"
}
