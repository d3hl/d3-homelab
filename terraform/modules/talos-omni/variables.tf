variable "cluster_name" {
  type        = string
  description = "Name of the Talos Omni cluster"
  default     = "d3Omni"
}

variable "talos_version" {
  type        = string
  description = "Talos Omni version to deploy"
  default     = "latest"
}

variable "control_plane_count" {
  type        = number
  description = "Number of control plane nodes"
  default     = 3
}

variable "worker_count" {
  type        = number
  description = "Number of worker nodes"
  default     = 3
}

variable "proxmox_nodes" {
  type        = list(string)
  description = "List of Proxmox nodes to distribute VMs across"
  default     = ["nodeA", "nodeB", "nodeD"]
}

variable "base_ip" {
  type        = string
  description = "Base IP address for the cluster (first octet will be used as starting point)"
  default     = "10.11.11.100"
}

variable "gateway" {
  type        = string
  description = "Network gateway IP"
  default     = "10.11.11.2"
}

variable "dns_servers" {
  type        = list(string)
  description = "DNS servers for nodes"
  default     = ["10.11.11.2"]
}

variable "cpu_cores" {
  type        = number
  description = "CPU cores per node"
  default     = 4
}

variable "memory_mb" {
  type        = number
  description = "Memory in MB per node"
  default     = 8192
}

variable "disk_size_gb" {
  type        = number
  description = "Disk size in GB per node"
  default     = 100
}

variable "datastore_id" {
  type        = string
  description = "Proxmox datastore for VM disks"
  default     = "cephVM"
}

variable "vm_template_id" {
  type        = number
  description = "Proxmox VM template ID to clone from"
  default     = 999
}

variable "virtual_environment_endpoint" {
  type        = string
  description = "Proxmox API endpoint"
  sensitive   = true
}

variable "virtual_environment_api_token" {
  type        = string
  description = "Proxmox API token"
  sensitive   = true
}

variable "virtual_environment_username" {
  type        = string
  description = "Proxmox API username"
  sensitive   = true
}

variable "virtual_environment_insecure" {
  type        = bool
  description = "Allow insecure TLS connections to Proxmox"
  default     = false
}


variable "ssh_public_key_path" {
  type        = string
  description = "Path to SSH public key for cloud-init"
  default     = "/home/d3/.ssh/d3_tf.pub"
}

variable "talos_machine_config_patch" {
  type        = string
  description = "Additional Talos machine config patch (JSON format)"
  default     = "{}"
}

variable "omni_controller_enabled" {
  type        = bool
  description = "Whether to provision a dedicated Omni controller VM"
  default     = true
}

variable "omni_controller_name" {
  type        = string
  description = "Name for the Omni controller VM"
  default     = "omni-controller"
}

variable "omni_controller_ip" {
  type        = string
  description = "Static management IP to reserve for Omni controller metadata"
  default     = "10.11.11.90"
}

variable "omni_controller_cpu_cores" {
  type        = number
  description = "CPU cores for the Omni controller VM"
  default     = 4
}

variable "omni_controller_memory_mb" {
  type        = number
  description = "Memory in MB for the Omni controller VM"
  default     = 8192
}

variable "omni_controller_disk_size_gb" {
  type        = number
  description = "Disk size in GB for the Omni controller VM"
  default     = 120
}

variable "omni_controller_proxmox_node" {
  type        = string
  description = "Proxmox node to host the Omni controller; defaults to first node in proxmox_nodes"
  default     = ""
}

variable "omni_controller_datastore_id" {
  type        = string
  description = "Datastore for Omni controller disk and snippets; defaults to datastore_id"
  default     = ""
}

variable "omni_controller_template_id" {
  type        = number
  description = "Template VM ID for Omni controller; defaults to vm_template_id"
  default     = 0
}

variable "omni_controller_image" {
  type        = string
  description = "Pinned Omni container image reference"
  default     = "ghcr.io/siderolabs/omni:v0.47.0"
}

variable "omni_controller_data_path" {
  type        = string
  description = "Persistent data path for Omni controller state on the VM"
  default     = "/var/lib/omni"
}

variable "omni_controller_domain" {
  type        = string
  description = "Optional DNS name for Omni controller endpoint"
  default     = ""
}

variable "omni_controller_tls_cert_path" {
  type        = string
  description = "Optional TLS certificate path on VM mounted into Omni container"
  default     = ""
}

variable "omni_controller_tls_key_path" {
  type        = string
  description = "Optional TLS private key path on VM mounted into Omni container"
  default     = ""
}

variable "omni_controller_tls_cert_pem" {
  type        = string
  description = "Optional PEM content for Omni TLS certificate written by cloud-init"
  default     = ""
  sensitive   = true
}

variable "omni_controller_tls_key_pem" {
  type        = string
  description = "Optional PEM content for Omni TLS private key written by cloud-init"
  default     = ""
  sensitive   = true
}

variable "omni_controller_direct_tls_termination" {
  type        = bool
  description = "Enable direct TLS termination on Omni; requires cert and key paths"
  default     = true
}

variable "omni_controller_rotate_tls_on_change" {
  type        = bool
  description = "Restart Omni container when TLS PEM content changes"
  default     = true
}
