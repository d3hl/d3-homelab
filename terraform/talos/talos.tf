# Cluster-wide PKI + token secrets.  Stored in Terraform state — treat as sensitive.
resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version
}

# ── Machine configurations ────────────────────────────────────────────────────

data "talos_machine_configuration" "controlplane" {
  for_each = var.controlplane_nodes

  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets

  config_patches = concat(
    [
      # Static IP + hostname for each control plane node.
      yamlencode({
        machine = {
          network = {
            hostname = each.key
            interfaces = [
              {
                interface = var.network_interface
                addresses = ["${each.value.ip}/${var.subnet_prefix}"]
                routes = [
                  {
                    network = "0.0.0.0/0"
                    gateway = var.gateway
                  }
                ]
              }
            ]
            nameservers = var.nameservers
          }
        }
      })
    ],
    var.allow_scheduling_on_controlplanes ? [
      yamlencode({
        cluster = {
          allowSchedulingOnControlPlanes = true
        }
      })
    ] : []
  )
}

data "talos_machine_configuration" "worker" {
  for_each = var.worker_nodes

  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.this.machine_secrets

  config_patches = [
    yamlencode({
      machine = {
        network = {
          hostname = each.key
          interfaces = [
            {
              interface = var.network_interface
              addresses = ["${each.value.ip}/${var.subnet_prefix}"]
              routes = [
                {
                  network = "0.0.0.0/0"
                  gateway = var.gateway
                }
              ]
            }
          ]
          nameservers = var.nameservers
        }
      }
    })
  ]
}

# ── Apply configurations ──────────────────────────────────────────────────────
# The Talos provider retries until the node is reachable in maintenance mode.
# VMs must have the configured IPs before this succeeds — set up DHCP
# reservations or ensure the IPs are available on the 10.10.10.x subnet.

resource "talos_machine_configuration_apply" "controlplane" {
  for_each = var.controlplane_nodes

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane[each.key].machine_configuration
  endpoint                    = each.value.ip
  node                        = each.value.ip

  depends_on = [proxmox_virtual_environment_vm.controlplane]
}

resource "talos_machine_configuration_apply" "worker" {
  for_each = var.worker_nodes

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker[each.key].machine_configuration
  endpoint                    = each.value.ip
  node                        = each.value.ip

  depends_on = [proxmox_virtual_environment_vm.worker]
}

# ── Bootstrap ─────────────────────────────────────────────────────────────────
# Initialises etcd on one control plane node.  Must run exactly once.
# var.bootstrap_ip must match the IP of one of the control plane nodes.

resource "talos_machine_bootstrap" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoint             = var.bootstrap_ip
  node                 = var.bootstrap_ip

  depends_on = [
    talos_machine_configuration_apply.controlplane,
    talos_machine_configuration_apply.worker,
  ]
}

# ── Cluster access ────────────────────────────────────────────────────────────

resource "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoint             = var.bootstrap_ip
  node                 = var.bootstrap_ip

  depends_on = [talos_machine_bootstrap.this]
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [for k, v in var.controlplane_nodes : v.ip]
  nodes = concat(
    [for k, v in var.controlplane_nodes : v.ip],
    [for k, v in var.worker_nodes : v.ip]
  )
}
