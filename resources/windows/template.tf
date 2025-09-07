# see https://registry.terraform.io/providers/bpg/proxmox/0.81.0/docs/data-sources/virtual_environment_vms
data "proxmox_virtual_environment_vms" "windows_templates" {
  tags = ["windows-2025-uefi", "template"] #tag
}

data "proxmox_virtual_environment_vm" "windows_template" {
  node_name = data.proxmox_virtual_environment_vms.windows_templates.vms[0].node_name
  vm_id     = data.proxmox_virtual_environment_vms.windows_templates.vms[0].vm_id
}

data "cloudinit_config" "example" {
  gzip          = false
  base64_encode = false
  part {
    filename     = "initialize-disks.ps1"
    content_type = "text/x-shellscript"
    content      = <<-EOF
      #ps1_sysnative
      # initialize all (non-initialized) disks with a single NTFS partition.
      # NB we have this script because disk initialization is not yet supported by cloudbase-init.
      # NB the output of this script appears on the cloudbase-init.log file when the
      #    debug mode is enabled, otherwise, you will only have the exit code.
      Get-Disk `
        | Where-Object {$_.PartitionStyle -eq 'RAW'} `
        | ForEach-Object {
          Write-Host "Initializing disk #$($_.Number) ($($_.Size) bytes)..."
          $volume = $_ `
            | Initialize-Disk -PartitionStyle MBR -PassThru `
            | New-Partition -AssignDriveLetter -UseMaximumSize `
            | Format-Volume -FileSystem NTFS -NewFileSystemLabel "disk$($_.Number)" -Confirm:$false
          Write-Host "Initialized disk #$($_.Number) ($($_.Size) bytes) as $($volume.DriveLetter):."
        }
      EOF
  }
  part {
    content_type = "text/cloud-config"
    content      = <<-EOF
      #cloud-config
      hostname: example
      timezone: Asia/Singapore
      users:
        - name: ${jsonencode(var.username)}
          passwd: ${jsonencode(var.password)}
          primary_group: Administrators
          ssh_authorized_keys:
            - ${jsonencode(trimspace(file("~/.ssh/id_ed.pub")))}
      # these runcmd commands are concatenated together in a single batch script and then executed by cmd.exe.
      # NB this script will be executed as the cloudbase-init user (which is in the Administrators group).
      # NB this script will be executed by the cloudbase-init service once, but to be safe, make sure its idempotent.
      # NB the output of this script appears on the cloudbase-init.log file when the
      #    debug mode is enabled, otherwise, you will only have the exit code.
      runcmd:
        - "echo # Script path"
        - "echo %~f0"
        - "echo # Sessions"
        - "query session"
        - "echo # whoami"
        - "whoami /all"
        - "echo # Windows version"
        - "ver"
        - "echo # Environment variables"
        - "set"
      EOF
  }
  part {
    filename     = "example.ps1"
    content_type = "text/x-shellscript"
    content      = <<-EOF
      #ps1_sysnative
      # this is a PowerShell script.
      # NB this script will be executed as the cloudbase-init user (which is in the Administrators group).
      # NB this script will be executed by the cloudbase-init service once, but to be safe, make sure its idempotent.
      # NB the output of this script appears on the cloudbase-init.log file when the
      #    debug mode is enabled, otherwise, you will only have the exit code.
      Start-Transcript -Append "C:\cloudinit-config-example.ps1.log"
      function Write-Title($title) {
        Write-Output "`n#`n# $title`n#"
      }
      Write-Title "Script path"
      Write-Output $PSCommandPath
      Write-Title "Sessions"
      query session | Out-String
      Write-Title "whoami"
      whoami /all | Out-String
      Write-Title "Windows version"
      cmd /c ver | Out-String
      Write-Title "Environment Variables"
      dir env:
      Write-Title "TimeZone"
      Get-TimeZone
      EOF
  }
}

# see https://registry.terraform.io/providers/bpg/proxmox/0.81.0/docs/resources/virtual_environment_file
resource "proxmox_virtual_environment_file" "example_ci_user_data" {
  content_type = "snippets"
  datastore_id = "cephfs"
  node_name    = pve10
  source_raw {
    file_name = "${var.prefix}-ci-user-data.txt"
    data      = data.cloudinit_config.example.rendered
  }
}

# see https://registry.terraform.io/providers/bpg/proxmox/0.81.0/docs/resources/virtual_environment_vm
resource "proxmox_virtual_environment_vm" "example" {
  name      = d3AD1
  node_name = pve10
  tags      = sort(["windows-2025-uefi", "terraform"])
  clone {
    vm_id = data.proxmox_virtual_environment_vm.windows_template.vm_id
    full  = false
  }
  cpu {
    type  = "host"
    cores = 4
  }
  memory {
    dedicated = 4 * 1024
  }
  network_device {
    bridge = "vmbr0"
  }
  disk {
    interface   = "scsi0"
    file_format = "raw"
    iothread    = true
    ssd         = true
    discard     = "on"
    size        = 64
  }
  disk {
    interface   = "scsi1"
    file_format = "raw"
    iothread    = true
    ssd         = true
    discard     = "on"
    size        = 16
  }
  agent {
    enabled = true
    trim    = true
  }
  # NB we use a custom user data because this terraform provider initialization
  #    block is not entirely compatible with cloudbase-init (the cloud-init
  #    implementation that is used in the windows base image).
  # see https://pve.proxmox.com/wiki/Cloud-Init_Support
  # see https://cloudbase-init.readthedocs.io/en/latest/services.html#openstack-configuration-drive
  # see https://registry.terraform.io/providers/bpg/proxmox/0.81.0/docs/resources/virtual_environment_vm#initialization
  initialization {
    user_data_file_id = proxmox_virtual_environment_file.example_ci_user_data.id
  }
  # NB this can only connect after about 3m15s (because the ssh service in the
  #    windows base image is configured as "delayed start").
  provisioner "remote-exec" {
    connection {
      target_platform = "windows"
      type            = "ssh"
      host            = self.ipv4_addresses[index(self.network_interface_names, "Ethernet")][0]
      user            = var.win_username
      password        = var.win_password
    }
    # NB this is executed as a batch script by cmd.exe.
    inline = [
      <<-EOF
      whoami.exe /all
      EOF
    ]
  }
}

output "ip" {
  value = proxmox_virtual_environment_vm.example.ipv4_addresses[index(proxmox_virtual_environment_vm.example.network_interface_names, "Ethernet")][0]
}