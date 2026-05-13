variable "OP_SERVICE_ACCOUNT_TOKEN" {
  type    = string
  default = ""
}

variable "datastore_id" {
  description = "Datastore for VM disks (Ceph RBD)"
  type        = string
  default     = "cephVM"
}

variable "iso_datastore_id" {
  description = "Datastore for qcow2 image download and cloud-init snippets (CephFS)"
  type        = string
  default     = "cFS"
}

variable "node_name" {
  description = "Proxmox node to deploy the AAP server on"
  type        = string
  default     = "nodeF"
}
# RHEL 10 KVM guest image — download from Red Hat Customer Portal (subscription required).
# Host it on an internal HTTP server or pass a pre-signed Red Hat URL.
# Image name: rhel-10.0-x86_64-kvm.qcow2
variable "rhel_qcow2" {
  description = "URL to the RHEL 10 KVM qcow2 guest image (Red Hat subscription required)"
  type        = string
  default     = "rhel-10"
}

variable "vm_ip" {
  description = "Static IP address for the AAP server in CIDR notation (e.g. 10.10.10.50/24)"
  type        = string
  default     = "10.10.10.49/24"
}

variable "vm_gateway" {
  description = "Default gateway for the AAP server"
  type        = string
  default     = "10.10.10.2"
}

variable "vm_id" {
  description = "Proxmox VM ID (0 = auto-assign)"
  type        = number
  default     = 0
}

variable "cpu_cores" {
  description = "vCPU cores for the AAP server (Red Hat minimum: 4)"
  type        = number
  default     = 8
}

variable "memory_mb" {
  description = "Memory in MB for the AAP server (Red Hat minimum: 16384)"
  type        = number
  default     = 32768
}

variable "disk_size_gb" {
  description = "Root disk size in GB"
  type        = number
  default     = 100
}
