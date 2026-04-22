#!/bin/bash
CFSSL_VERSION=$(curl -sI https://github.com/cloudflare/cfssl/releases/latest \
  | grep -i location | awk -F '/' '{print $NF}' | tr -d '\r')

curl -L -o cfssl \
  https://github.com/cloudflare/cfssl/releases/download/${CFSSL_VERSION}/cfssl_${CFSSL_VERSION#v}_linux_amd64
curl -L -o cfssljson \
  https://github.com/cloudflare/cfssl/releases/download/${CFSSL_VERSION}/cfssljson_${CFSSL_VERSION#v}_linux_amd64

chmod +x cfssl cfssljson
sudo mv cfssl cfssljson /usr/local/bin/

echo "127.0.0.1 omni.d3hl.site auth.d3hl.site" | sudo tee -a /etc/hosts