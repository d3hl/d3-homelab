variable "virtual_environment_endpoint" {
  type = string
}

variable "virtual_environment_api_token" {
  description = "The API token for the Proxmox Virtual Environment API"
  type        = string
  sensitive   = true
}

variable "virtual_environment_username" {
  description = "Username used for Proxmox SSH operations"
  type        = string
  default     = "d3"
}

variable "datastore_id" {
  type        = string
  description = "Datastore for VM disks"
  default     = "cephVM"
}

variable "ubuntu_template_id" {
  type        = number
  description = "Ubuntu template VM ID used as clone source"
  default     = 999
}

variable "komodo_node_map" {
  type        = map(string)
  description = "Komodo VM name to Proxmox node mapping"
  default = {
    k1 = "pveA"
    k2 = "pveB"
    k3 = "nodeD"
    k4 = "nodeF"
  }
}

variable "cpu_cores" {
  type        = number
  description = "CPU cores allocated per Komodo VM"
  default     = 2
}

variable "memory_mb" {
  type        = number
  description = "Memory allocated per Komodo VM (MB)"
  default     = 16384
}

variable "memory_balloon_mb" {
  type        = number
  description = "Minimum balloon memory per Komodo VM (MB)"
  default     = 8192
}

variable "disk_size_gb" {
  type        = number
  description = "Disk size per Komodo VM (GB)"
  default     = 100
}
