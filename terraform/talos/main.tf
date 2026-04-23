# Download the Talos metal ISO to a Proxmox storage node.
# The ISO is shared across all VMs; only one copy is needed.
resource "proxmox_download_file" "talos_iso" {
  content_type = "iso"
  datastore_id = var.iso_datastore_id
  node_name    = var.iso_node
  url          = "https://factory.talos.dev/image/0adff2c778cb465251187dbe20eb4ee05d86d9c3593892863721bcb5615af08c/1.12.6/nocloud-amd64.iso"
  file_name    = "talos-nocloud-amd64-uefi.iso"
}

# Control plane VMs.
# UEFI boot order: OVMF tries virtio0 first; since the disk has no EFI boot
# entry on first run, it falls through to the secureboot ISO on ide2. After
# Talos installs itself, it writes an EFI boot entry to virtio0 and subsequent
# reboots boot from disk automatically.
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

  # EFI vars disk — required for OVMF. Pre-enroll Secure Boot keys so the
  # secureboot-signed Talos ISO is accepted without manual key enrollment.
  efi_disk {
    datastore_id      = var.datastore_id
    type              = "4m"
    pre_enrolled_keys = true
  }

  # Empty boot disk — Talos installs here after receiving its machine config.
  disk {
    datastore_id = var.datastore_id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = var.controlplane_disk_size_gb
  }

  # Talos secureboot ISO for the initial maintenance-mode boot.
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
