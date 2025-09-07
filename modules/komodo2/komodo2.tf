data "proxmox_virtual_environment_vms" "debian_template" {
  tags = ["debian", "template"]
}
resource "proxmox_virtual_environment_file" "meta_data_cloud_config" {
  content_type = "snippets"
  datastore_id = "cephfs"
  node_name    = var.virtual_environment_node2_name
    source_raw {
    data = <<-EOF
    #cloud-config
    local-hostname: komodo2
    EOF

    file_name = "meta-data-cloud-config.yaml"
  }
}
resource "proxmox_virtual_environment_vm" "komodo2" {
  name      = "komodo2"
  node_name = var.virtual_environment_node2_name
  tags      = sort(["debian", "terraform","komodo"])
  # should be true if qemu agent is not installed / enabled on the VM
  started  = false

  machine     = "q35"
  bios        = "ovmf"
  description = "Managed by Terraform"

    agent {
    enabled = true
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  efi_disk {
    datastore_id = var.datastore_id
    type         = "4m"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    datastore_id = var.datastore_id
    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
    meta_data_file_id = proxmox_virtual_environment_file.meta_data_cloud_config.id
    //user_data_file_id = proxmox_virtual_environment_file.cloud_config.id       
  }
    disk {
    datastore_id = "cVM"
    file_id   = "cephfs:iimport/debian-12-genericcloud-amd64.qcow2"
    interface = "virtio0"
    iothread  = true
    discard   = "on"
    size      = 20
  }
  network_device {
    bridge = "vmbr0"
    vlan_id = 10
  }

}
output "vm_ipv4_address" {
  value = proxmox_virtual_environment_vm.komodo2.ipv4_addresses[1][0]
}