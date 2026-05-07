#!/bin/bash
export HOST_PUBLIC_IP=10.10.10.40
export HOST_PRIVATE_IP=10.11.11.40
export OMNI_ENDPOINT=omni.d3hl.site
export AUTH_ENDPOINT=auth.d3hl.site
export OMNI_USER_EMAIL="d3tech@pm.me"


TARGET_ENV="d3hl" op inject -f -i ".env.tpl" -o ".env"
#TARGET_ENV="d3hl" op inject -f -i "cloudflare.tpl" -o "cloudflare.ini"
TARGET_ENV="d3hl" op inject -f -i "./omni.tpl" -o "omni.asc"
TARGET_ENV="d3hl" op inject -f -i "./certs/server-chain.pem.tpl" -o "server-chain.pem"
TARGET_ENV="d3hl" op inject -f -i "./certs/server-key.pem.tpl" -o "server-key.pem"
TARGET_ENV="d3hl" op inject -f -i "./certs/ca.pem.tpl" -o "ca.pem"
TARGET_ENV="d3hl" op inject -f -i "./dex.tpl" -o "dex.yaml"