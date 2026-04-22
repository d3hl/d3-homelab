#!/bin/bash


gpg --batch --passphrase '' \
  --quick-generate-key \
  "Omni (Used for etcd data encryption) d3tech@pm.me" \
  rsa4096 cert never

FINGERPRINT=$(gpg --with-colons --list-keys "d3tech@pm.me" \
  | awk -F: '$1 == "fpr" {print $10; exit}')

gpg --batch --passphrase '' \
  --quick-add-key ${FINGERPRINT} rsa4096 encr never

gpg --export-secret-key --armor d3tech@pm.me > omni.asc