data "local_file" "ssh_public_key" {
  filename = var.ssh_public_key_path
}

locals {
  node_config = {
    for i in range(var.control_plane_count + var.worker_count) : i => {
      name         = i < var.control_plane_count ? "talos-cp-${i + 1}" : "talos-worker-${i - var.control_plane_count + 1}"
      ip           = "10.11.11.${100 + i}"
      node_index   = i
      is_cp        = i < var.control_plane_count
      proxmox_node = var.proxmox_nodes[i % length(var.proxmox_nodes)]
    }
  }

  omni_controller_target_node = var.omni_controller_proxmox_node != "" ? var.omni_controller_proxmox_node : var.proxmox_nodes[0]
  omni_controller_datastore   = var.omni_controller_datastore_id != "" ? var.omni_controller_datastore_id : var.datastore_id
  omni_controller_template    = var.omni_controller_template_id != 0 ? var.omni_controller_template_id : var.vm_template_id
  omni_controller_tls_cert_effective_path = var.omni_controller_tls_cert_path != "" ? var.omni_controller_tls_cert_path : (
    var.omni_controller_tls_cert_pem != "" ? "/etc/omni/tls.crt" : ""
  )
  omni_controller_tls_key_effective_path = var.omni_controller_tls_key_path != "" ? var.omni_controller_tls_key_path : (
    var.omni_controller_tls_key_pem != "" ? "/etc/omni/tls.key" : ""
  )
  omni_controller_tls_material_hash = (var.omni_controller_tls_cert_pem != "" || var.omni_controller_tls_key_pem != "") ? sha256(
    join("\n---\n", [var.omni_controller_tls_cert_pem, var.omni_controller_tls_key_pem])
  ) : ""

  cloud_config_omni_content = templatefile("${path.module}/cloud-config-omni.tpl", {
    cluster_name                  = var.cluster_name
    ssh_key                       = trimspace(data.local_file.ssh_public_key.content)
    omni_controller_image         = var.omni_controller_image
    omni_controller_data_path     = var.omni_controller_data_path
    omni_controller_domain        = var.omni_controller_domain
    omni_controller_tls_cert_path = local.omni_controller_tls_cert_effective_path
    omni_controller_tls_key_path  = local.omni_controller_tls_key_effective_path
    omni_controller_tls_cert_pem  = var.omni_controller_tls_cert_pem
    omni_controller_tls_key_pem   = var.omni_controller_tls_key_pem
    omni_controller_direct_tls_termination = var.omni_controller_direct_tls_termination
    omni_controller_rotate_tls_on_change   = var.omni_controller_rotate_tls_on_change
    omni_controller_tls_material_hash      = local.omni_controller_tls_material_hash
  })
}

