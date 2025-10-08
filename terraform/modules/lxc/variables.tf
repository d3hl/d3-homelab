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
variable "virtual_environment_pve10_name" {
  description = "Name of the Proxmox node"
  type        = string
  default     = "pve10"
}
variable "virtual_environment_node2_name" {
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
  default     = "cVM"
}
variable "ssh_public_key" {
  type = string
  sensitive = true
}

variable "latest_debian_12_bookworm_qcow2_img_url" {
  description = "The URL for the latest Debian 12 Bookworm qcow2 image"
  type        = string
  default     = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
}
variable "virtual_environment_storage" {
  description = "Name of the Proxmox storage"
  type        = string
  default     = "cVM"
}