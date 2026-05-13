# Downloads the RHEL 10 KVM guest image to Proxmox storage.
# Stored as content_type "iso" so Proxmox accepts it; BPG imports it as a
# disk image when referenced via file_id in the disk block below.
resource "proxmox_download_file" "rhel10_qcow2" {
  content_type = "import"
  datastore_id = var.iso_datastore_id
  node_name    = var.node_name
  url          = var.rhel_qcow2
  file_name    = "rhel-10.0-x86_64-kvm.qcow2"
}

resource "proxmox_virtual_environment_vm" "aap_server" {
  name      = "hl-sg-aap"
  node_name = var.node_name
  vm_id     = var.vm_id != 0 ? var.vm_id : null
  machine   = "q35"
  bios      = "ovmf"
  tags      = ["rhel", "aap"]

  efi_disk {
    datastore_id      = var.datastore_id
    type              = "4m"
    pre_enrolled_keys = true
  }

  cpu {
    cores = var.cpu_cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.memory_mb
  }

  # Root disk imported from the RHEL 10 qcow2 image and expanded to disk_size_gb
  disk {
    datastore_id = var.datastore_id
    file_id      = proxmox_download_file.rhel10_qcow2.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
  }

  # Cloud-init drives initial SSH key and static IP injection
  initialization {
    datastore_id = var.iso_datastore_id

    ip_config {
      ipv4 {
        address = var.vm_ip
        gateway = var.vm_gateway
      }
    }
  }

  boot_order = ["virtio0"]

  network_device {
    bridge  = "vmbr0"
    model   = "virtio"
    vlan_id = 10
  }

  operating_system {
    type = "l26"
  }
}
