#!/usr/bin/env bash
set -euo pipefail

VM_ID="${VM_ID:-9906}"
VM_NAME="${VM_NAME:-rhel9-aap-bootc-template}"
NODE_STORAGE="${NODE_STORAGE:-cephVM}"
SNIPPET_STORAGE="${SNIPPET_STORAGE:-cFS}"
QCOW2_PATH="${QCOW2_PATH:-output/qcow2/disk.qcow2}"

qm create "${VM_ID}" \
  --name "${VM_NAME}" \
  --memory 4096 \
  --cores 2 \
  --cpu host \
  --net0 virtio,bridge=vmbr0 \
  --agent enabled=1 \
  --ostype l26

qm importdisk "${VM_ID}" "${QCOW2_PATH}" "${NODE_STORAGE}"
qm set "${VM_ID}" --scsihw virtio-scsi-pci --scsi0 "${NODE_STORAGE}:vm-${VM_ID}-disk-0"
qm set "${VM_ID}" --ide2 "${SNIPPET_STORAGE}:cloudinit"
qm set "${VM_ID}" --boot order=scsi0
qm set "${VM_ID}" --serial0 socket --vga serial0
qm template "${VM_ID}"

