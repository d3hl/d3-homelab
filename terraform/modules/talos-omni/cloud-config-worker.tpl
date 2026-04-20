#cloud-config
hostname: ${cluster_name}-worker
timezone: Asia/Singapore

users:
  - default
  - name: d3
    groups:
      - sudo
    shell: /bin/bash
    ssh_authorized_keys:
      - ${trimspace(ssh_key)}
    sudo: ALL=(ALL) NOPASSWD:ALL

package_update: true
packages:
  - qemu-guest-agent
  - net-tools
  - curl
  - wget
  - systemd-resolved

runcmd:
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
  - systemctl enable systemd-resolved
  - systemctl start systemd-resolved
  - mkdir -p /opt/talos
  - echo "Talos Omni Worker Node Ready" > /tmp/talos-ready.txt
