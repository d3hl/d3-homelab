#cloud-config
hostname: ${cluster_name}-omni
timezone: Asia/Singapore

users:
  - default
  - name: d3
    groups:
      - sudo
      - docker
    shell: /bin/bash
    ssh_authorized_keys:
      - ${trimspace(ssh_key)}
    sudo: ALL=(ALL) NOPASSWD:ALL

package_update: true
packages:
  - qemu-guest-agent
  - curl
  - ca-certificates
  - docker.io

runcmd:
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
  - systemctl enable docker
  - systemctl start docker
  - mkdir -p ${omni_controller_data_path}
  - |
    cat > /usr/local/bin/start-omni.sh <<'EOF'
    #!/usr/bin/env bash
    set -euo pipefail
    TLS_MOUNT_ARGS=""
    TLS_ARGS=""
    if [ "${omni_controller_direct_tls_termination}" = "true" ]; then
      if [ -z "${omni_controller_tls_cert_path}" ] || [ -z "${omni_controller_tls_key_path}" ]; then
        echo "Direct TLS termination is enabled but cert/key paths are missing" >&2
        exit 1
      fi
      TLS_MOUNT_ARGS="-v ${omni_controller_tls_cert_path}:/certs/tls.crt:ro -v ${omni_controller_tls_key_path}:/certs/tls.key:ro"
      TLS_ARGS="--tls-cert-path /certs/tls.crt --tls-key-path /certs/tls.key"
    fi
    DOMAIN_ARGS=""
    if [ -n "${omni_controller_domain}" ]; then
      DOMAIN_ARGS="--public-endpoint https://${omni_controller_domain}"
    fi
    docker rm -f omni-controller >/dev/null 2>&1 || true
    # shellcheck disable=SC2086
    docker run -d \
      --name omni-controller \
      --restart unless-stopped \
      -p 443:443 \
      -p 8099:8099 \
      -v ${omni_controller_data_path}:/var/lib/omni \
      ${TLS_MOUNT_ARGS} \
      ${omni_controller_image} \
      ${DOMAIN_ARGS} ${TLS_ARGS}
    EOF
  - chmod +x /usr/local/bin/start-omni.sh
  - /usr/local/bin/start-omni.sh
  - echo "Omni controller initialized" > /tmp/omni-ready.txt
