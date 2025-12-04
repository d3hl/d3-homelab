terraform {
  required_providers {
    iosxe = {
      source  = "CiscoDevNet/iosxe"
      version = "0.11.0"
    }
  }
}

provider "iosxe" {
  # Configuration options
  username    = var.username
  password    = var.password
  host        = var.host
  protocol    = "netconf"
  auto_commit = true
  # Device list
  selected_devices = ["d39k3"]
  devices = [
    { name = "d39k3", host = "10.10.10.1" },    # Managed
    { name = "switch-02", host = "10.1.1.20" }, # Managed
    { name = "switch-03", host = "10.1.1.30" }, # Skipped
    { name = "switch-04", host = "10.1.1.40" }  # Skipped
  ]
}