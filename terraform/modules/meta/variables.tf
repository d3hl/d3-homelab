variable "virtual_environment_nodeA_name" {
  description = "The name of the Proxmox node where the cloud-config file will be stored"
  type        = string
}

variable "datastore_id" {
  description = "The datastore ID where the cloud-config snippet will be stored"
  type        = string
  default     = "cFS"
}

variable "hostname" {
  description = "The hostname to set in the meta-data cloud-config"
  type        = string
  default     = "kmd1"
}
