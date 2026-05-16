#!/usr/bin/env bash
set -euo pipefail

IMAGE="${IMAGE:-localhost/aap-rhel9-bootc:homelab}"
CONFIG="${CONFIG:-image/bootc-image-builder.config.toml}"
OUTPUT_DIR="${OUTPUT_DIR:-output}"

if [[ ! -f "${CONFIG}" ]]; then
  echo "Missing ${CONFIG}. Copy image/bootc-image-builder.config.toml.example and add the d3 SSH public key."
  exit 1
fi

podman login registry.redhat.io
podman build -t "${IMAGE}" -f image/Containerfile image

mkdir -p "${OUTPUT_DIR}"

podman run \
  --rm \
  --privileged \
  --pull=newer \
  --security-opt label=type:unconfined_t \
  -v "$(pwd)/${CONFIG}:/config.toml:ro" \
  -v "$(pwd)/${OUTPUT_DIR}:/output" \
  registry.redhat.io/rhel9/bootc-image-builder:latest \
  --type qcow2 \
  --config /config.toml \
  "${IMAGE}"

