packer {
    required_plugins {
        name = {
            version = "~> 1"
            source  = "github.com/hashicorp/proxmox"
    }
    #sshkey = {
    #  version = ">= 1.2.1"
    #  source = "github.com/ivoronin/sshkey"
    #}
    }
}

variable "proxmox_api_url" {
    type = string
}

variable "proxmox_api_token_id" {
    type = string
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
    
}

#variables {
#  temporary_key_pair_name = "my_temp_key"
#}
#data "sshkey" "install" {
#  name = var.temporary_key_pair_name
#}

variable "ssh_authorized_keys" {
    type      = list(string)
    sensitive = true
    default   = []
}

source "proxmox-iso" "ubuntu-server-resolute" {
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"
    insecure_skip_tls_verify = true

    # VM General Settingi
    node = "nodeD"
    vm_id = "999"
    vm_name = "ubuntu-2604"
    template_description = "Ubuntu Server Resolute from Packer"

    # VM System Settings
    qemu_agent = true

    # VM Hard Disk Settings
    scsi_controller = "virtio-scsi-pci"

    disks {
        type = "virtio"
        disk_size = "100G"
        storage_pool = "cephVM"
    }

    boot_iso {
        type = "scsi"
        iso_file = "cFS:iso/ubuntu-26.04-live-server-amd64.iso"
        unmount = true
    }

    # VM CPU Settings
    cores = "2"
    cpu_type = "host"

    # VM Memory Settings
    memory = "4096"

    # VM Network Settings
    network_adapters {
        model = "virtio"
        bridge = "vmbr0"
        firewall = "false"
        vlan_tag = "10"
    }

    cloud_init              = true
    cloud_init_storage_pool = "cephVM"


    ssh_username = "d3"
## The build takes forever, 60 is more than enough
    ssh_timeout  = "60m"
    ssh_private_key_file = "~/.ssh/d3_tf"

    boot_wait = "10s"
    boot_command = [
        "<esc><wait>",
        "e<wait>",
        "<down><down><down><end>",
        "<bs><bs><bs><bs><wait>",
        "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
        "<f10><wait>"
    ]

    http_content = {
      "/user-data" = local.user_data
      "/meta-data" = "instance-id: packer\nlocal-hostname: ubuntu-questing-template"
    }
    http_port_min = 8001
    http_port_max = 8001
}


build {
  hcp_packer_registry {
    bucket_name = "ubuntu-resolute"
    description = "Image for Proxmox"

    bucket_labels = {
      "owner"          = "d3"
      "os"             = "Ubuntu",
      "ubuntu-version" = "Resolute 26.04",
    }

    build_labels = {
      "build-time"   = timestamp()
      "build-source" = basename(path.cwd)
    }
  }

#  sources = [
 #   "source.amazon-ebs.basic-example-east",
  #  "source.amazon-ebs.basic-example-west"
  #]

    name = "ubuntu-server-resolute"
    sources = ["source.proxmox-iso.ubuntu-server-resolute"]

    ## Cleanup for re-template
    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt -y autoremove --purge",
            "sudo apt -y clean",
            "sudo apt -y autoclean",
            "sudo cloud-init clean",
            "sudo rm -f /var/lib/dbus/machine-id",
            "sudo rm -f /var/lib/systemd/random-seed",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo rm -f /etc/netplan/00-installer-config.yaml",
            "sudo sync"
        ]
    }

    provisioner "file" {
        source = "ubuntu/files/pve.cfg"
        destination = "/tmp/pve.cfg"
    }

    provisioner "shell" {
        inline = [ "sudo cp /tmp/pve.cfg /etc/cloud/cloud.cfg.d/pve.cfg" ]
    }

    provisioner "file" {
        source = "ubuntu/files/setup-ubuntu.sh"
        destination = "/tmp/setup-ubuntu.sh"
    }


    provisioner "shell" {
        inline = [
            "chmod +x /tmp/setup-ubuntu.sh",
            "/tmp/setup-ubuntu.sh"
        ]
    }

    provisioner "file" {
        source = "ubuntu/files/.zshrc"
        destination = "~/.zshrc"
    }
}

locals {
    user_data = templatefile("../files/cloud-init.pkrtpl.hcl", {
    ssh_authorized_keys = join("\n", var.ssh_authorized_keys)
})
}