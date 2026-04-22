#!/bin/bash
cat <<EOF > ca-csr.json
{
  "CN": "Internal Root CA",
  "key": { "algo": "rsa", "size": 4096 },
  "names": [{ "C": "US", "O": "Internal Infrastructure", "OU": "Security" }]
}
EOF

cfssl gencert -initca ca-csr.json | cfssljson -bare ca
sudo cp ca.pem /usr/local/share/ca-certificates/ca.crt
sudo update-ca-certificates

cat <<EOF > ca-config.json
{
  "signing": {
    "default": { "expiry": "8760h" },
    "profiles": {
      "web-server": {
        "usages": ["signing", "key encipherment", "server auth"],
        "expiry": "8760h"
      },
      "client": {
        "usages": ["signing", "key encipherment", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
EOF

cat <<EOF > wildcard-csr.json
{
  "CN": "Internal Wildcard",
  "hosts": [
    "omni.d3hl.site",
    "auth.d3hl.site",
    "127.0.0.1",
    "10.10.10.40",
    "10.11.11.40"
  ],
  "key": { "algo": "rsa", "size": 4096 }
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=web-server wildcard-csr.json | cfssljson -bare server

  cat server.pem ca.pem > server-chain.pem
  chmod 644 server*.pem