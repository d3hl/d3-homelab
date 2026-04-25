variable "virtual_environment_endpoint" {
  type = string
}

variable "virtual_environment_api_token" {
  description = "The API token for the Proxmox Virtual Environment API"
  type        = string
  sensitive   = true
}


variable "virtual_environment_node_name" {
  description = "Default Proxmox node for this workspace (nodeD)"
  type        = string
  default     = "nodeD"
}
variable "virtual_environment_nodeA" {
  description = "Name of the Proxmox node"
  type        = string
  default     = "nodeA"
}
variable "virtual_environment_node_nodeF" {
  description = "Name of the Proxmox node"
  type        = string
  default     = "nodeF"
}
variable "datastore_id" {
  description = "Datastore for VM disks (Ceph RBD)"
  type        = string
  description = "Datastore for VM disks"
  default     = "cephVM"
}

variable "snippets_datastore_id" {
  description = "Datastore for cloud-init snippets and ISO imports (shared CephFS)"
  type        = string
  default     = "cFS"
}

variable "ubuntu_template" {
  type    = string
  default = "999"
}
