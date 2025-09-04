variable "virtual_environment_endpoint" {
  description = "The endpoint for the Proxmox Virtual Environment API (example: https://host:port)"
  type        = string
}
variable "virtual_environment_api_token" {
  description = "The API token for the Proxmox Virtual Environment API"
  type        = string
  sensitive   = true
}

