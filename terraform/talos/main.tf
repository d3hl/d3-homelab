# Upload the Omni-registered Talos ISO to Proxmox storage.
# Generate this ISO AFTER Omni is running:
#   omnictl download iso --arch amd64 --output talos-omni-amd64.iso
# Then set var.omni_iso_url to a reachable URL or upload manually.
resource "proxmox_download_file" "talos_iso" {
  content_type = "iso"
  datastore_id = var.iso_datastore_id
  node_name    = var.iso_node
  url          = var.omni_iso_url
  file_name    = "talos-omni-amd64.iso"
}

# Control plane VMs.
# UEFI boot order: OVMF tries virtio0 first; since the disk has no EFI boot
# entry on first run, it falls through to the Omni ISO on ide2. Talos installs
# itself, writes an EFI boot entry to virtio0, and phones home to Omni via
# SideroLink. Subsequent reboots boot from disk automatically.
resource "proxmox_virtual_environment_vm" "controlplane" {
  for_each = var.controlplane_nodes

  node_name = each.value.pve_node
  name      = each.key
  machine   = "q35"
  bios      = "ovmf"

  cpu {
    cores = var.controlplane_cpu_cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.controlplane_memory_mb
  }

  efi_disk {
    datastore_id      = var.datastore_id
    type              = "4m"
    pre_enrolled_keys = true
  }

  disk {
    datastore_id = var.datastore_id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = var.controlplane_disk_size_gb
  }

  cdrom {
    enabled   = true
    file_id   = proxmox_download_file.talos_iso.id
    interface = "ide2"
  }

  boot_order = ["virtio0", "ide2"]

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  operating_system {
    type = "l26"
  }
}

# Worker VMs — identical structure to control planes, different sizing vars.
resource "proxmox_virtual_environment_vm" "worker" {
  for_each = var.worker_nodes

  node_name = each.value.pve_node
  name      = each.key
  machine   = "q35"
  bios      = "ovmf"

  cpu {
    cores = var.worker_cpu_cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.worker_memory_mb
  }

  efi_disk {
    datastore_id      = var.datastore_id
    type              = "4m"
    pre_enrolled_keys = true
  }

  disk {
    datastore_id = var.datastore_id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = var.worker_disk_size_gb
  }

  cdrom {
    enabled   = true
    file_id   = proxmox_download_file.talos_iso.id
    interface = "ide2"
  }

  boot_order = ["virtio0", "ide2"]

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  operating_system {
    type = "l26"
  }
}
