variable "virtual_environment_endpoint" {
  description = "Proxmox API endpoint URL, for example https://10.10.10.10:8006/"
  type        = string
}

variable "virtual_environment_api_token" {
  description = "Proxmox API token in user@realm!tokenid=secret format"
  type        = string
  sensitive   = true
}

variable "virtual_environment_username" {
  description = "Username for Proxmox SSH operations"
  type        = string
  default     = "d3"
}

variable "rhel_bootc_template_vm_id" {
  description = "Proxmox template VM ID created from the RHEL bootc QCOW2"
  type        = number
  default     = 9906
}

variable "rhel_bootc_template_node" {
  description = "Proxmox node where the RHEL bootc template resides"
  type        = string
  default     = "nodeF"
}

variable "virtual_environment_node_name" {
  description = "Default Proxmox node for AAP image-mode VMs"
  type        = string
  default     = "nodeD"
}

variable "datastore_id" {
  description = "Datastore for VM disks"
  type        = string
  default     = "cephVM"
}

variable "network_bridge" {
  description = "Proxmox bridge for AAP VMs"
  type        = string
  default     = "vmbr0"
}

variable "network_gateway" {
  description = "Default gateway for AAP VMs"
  type        = string
  default     = "10.10.10.1"
}

variable "network_vlan_tag" {
  description = "Optional VLAN tag. Leave null for untagged vmbr0 traffic."
  type        = number
  default     = null
}

variable "aap_dns_domain" {
  description = "Internal DNS suffix for AAP FQDNs"
  type        = string
  default     = "homelab.local"
}

variable "aap_nodes" {
  description = "AAP image-mode VM sizing and addressing"
  type = map(object({
    role     = string
    ip       = string
    cores    = number
    memory   = number
    disk     = number
    node     = optional(string)
    template = optional(number)
  }))
  default = {
    gateway = {
      role   = "gateway"
      ip     = "10.10.10.60/24"
      cores  = 4
      memory = 16384
      disk   = 60
    }
    controller = {
      role   = "controller-eda"
      ip     = "10.10.10.61/24"
      cores  = 4
      memory = 32768
      disk   = 80
    }
    hub = {
      role   = "hub"
      ip     = "10.10.10.62/24"
      cores  = 4
      memory = 16384
      disk   = 100
    }
    db = {
      role   = "database"
      ip     = "10.10.10.63/24"
      cores  = 4
      memory = 16384
      disk   = 80
    }
  }
}

