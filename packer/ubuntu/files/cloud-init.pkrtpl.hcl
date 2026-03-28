#cloud-config
autoinstall:
  version: 1
  locale: en_US
  keyboard:
    layout: us
  identity:
    hostname: ubuntu-noble-template
    username: d3
    password: 58b3aca37bd5407cd9b530cf881503ec3bcf13566d676578 
  storage:
    layout:
      name: direct
  ssh:
    install-server: true
    allow-pw: false
    disable_root: true
    ssh_quiet_keygen: true
    allow_public_ssh_keys: true
  packages:
    - qemu-guest-agent
    - ca-certificates
    - curl
    - git
    - zsh
    - gnupg
    - nfs-common
    - net-tools
    - fzf
  user-data:
    package_upgrade: false
    timezone: Asia/Singapore
    users:
      - name: d3
        groups: [sudo]
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/zsh
        ssh_authorized_keys:
%{ for key in split("\n", ssh_authorized_keys) ~}
          - ${key}
%{ endfor ~}
  early-commands:
    - echo 'Packer build starting' > /tmp/packer-start.log