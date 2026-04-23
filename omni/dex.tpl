issuer: "op://d3HL/omni_env/Basic/dex.yaml.issuer"

storage:
  type: memory

web:
  https: 0.0.0.0:5556
  tlsCert: /etc/dex/tls/server-chain.pem
  tlsKey: /etc/dex/tls/server-key.pem

enablePasswordDB: true

staticClients:
  - name: Omni
    id: omni
    secret: omni-dex-secret
    redirectURIs:
      - "op://d3HL/omni_env/Basic/dex.yaml.redirect"

staticPasswords:
  - email: "op://d3HL/omni_env/Basic/email"
    username: "d3"
    preferredUsername: "d3"
    hash: "op://d3HL/Terraform Proxmox GitOps.env/password"