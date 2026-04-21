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
%{ if omni_controller_tls_cert_pem != "" || omni_controller_tls_key_pem != "" }

write_files:
%{ if omni_controller_tls_cert_pem != "" }
  - path: ${omni_controller_tls_cert_path}
    owner: root:root
    permissions: "0644"
    content: |
${indent(6, trimspace(omni_controller_tls_cert_pem))}
%{ endif }
%{ if omni_controller_tls_key_pem != "" }
  - path: ${omni_controller_tls_key_path}
    owner: root:root
    permissions: "0600"
    content: |
${indent(6, trimspace(omni_controller_tls_key_pem))}
%{ endif }
%{ endif }

runcmd:
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
  - systemctl enable docker
  - systemctl start docker
  - mkdir -p /etc/omni
  - mkdir -p ${omni_controller_data_path}
  - |
    cat > /usr/local/bin/start-omni.sh <<'EOF'
    #!/usr/bin/env bash
    set -euo pipefail
    TLS_MOUNT_ARGS=""
    TLS_ARGS=""
    TLS_HASH_FILE="${omni_controller_data_path}/.tls-material.sha256"
    CURRENT_TLS_HASH="${omni_controller_tls_material_hash}"
    SHOULD_RESTART=false
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
    if ! docker ps -a --format '{{.Names}}' | grep -Fxq "omni-controller"; then
      SHOULD_RESTART=true
    fi
    if [ "${omni_controller_rotate_tls_on_change}" = "true" ] && [ -n "$${CURRENT_TLS_HASH}" ]; then
      PREVIOUS_TLS_HASH=""
      if [ -f "$${TLS_HASH_FILE}" ]; then
        PREVIOUS_TLS_HASH="$(cat "$${TLS_HASH_FILE}")"
      fi
      if [ "$${PREVIOUS_TLS_HASH}" != "$${CURRENT_TLS_HASH}" ]; then
        SHOULD_RESTART=true
      fi
    fi
    if [ "$${SHOULD_RESTART}" = "true" ]; then
      docker rm -f omni-controller >/dev/null 2>&1 || true
    fi
    if [ "$${SHOULD_RESTART}" != "true" ] && docker ps --format '{{.Names}}' | grep -Fxq "omni-controller"; then
      exit 0
    fi
    # shellcheck disable=SC2086
    docker run -d \
      --name omni-controller \
      --restart unless-stopped \
      -p 443:443 \
      -p 8099:8099 \
      -v ${omni_controller_data_path}:/var/lib/omni \
      $${TLS_MOUNT_ARGS} \
      ${omni_controller_image} \
      $${DOMAIN_ARGS} $${TLS_ARGS}
    if [ "${omni_controller_rotate_tls_on_change}" = "true" ] && [ -n "$${CURRENT_TLS_HASH}" ]; then
      echo "$${CURRENT_TLS_HASH}" > "$${TLS_HASH_FILE}"
    fi
    EOF
  - chmod +x /usr/local/bin/start-omni.sh
  - /usr/local/bin/start-omni.sh
  - echo "Omni controller initialized" > /tmp/omni-ready.txt
