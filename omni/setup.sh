#!/bin/bash
export HOST_PUBLIC_IP=10.10.10.40
export HOST_PRIVATE_IP=10.11.11.40
export OMNI_ENDPOINT=omni.d3hl.site
export AUTH_ENDPOINT=auth.d3hl.site
export OMNI_USER_EMAIL="d3tech@pm.me"

bash ./scripts/cfssl.sh
bash ./scripts/ca.sh
bash ./scripts/setup-gbg.sh
