NAME=omni
OMNI_IMG_TAG="op://d3HL/omni_env/OMNI_IMG_TAG"
OMNI_DOMAIN_NAME="op://d3HL/omni_env/OMNI_DOMAIN_NAME"

TLS_CERT="op://d3HL/omni_env/TLS_CERT"
TLS_KEY="op://d3HL/omni_env/TLS_KEY"

# Path to SQLite storage directory on host (NEW in v1.4.0 - REQUIRED)
# This consolidates Discovery service state, Audit logs, Machine logs, and Secondary resources
SQLITE_STORAGE_PATH=/home/d3/sqlite/

# Path to GPG key file (exported with: gpg --export-secret-key --armor)
ETCD_ENCRYPTION_KEY=/home/d3/d3-homelab/omni/certs/omni.asc

HOST_PUBLIC_IP=10.10.10.40
HOST_PRIVATE_IP=10.11.11.40
OMNI_ENDPOINT=omni.d3hl.site
AUTH_ENDPOINT=auth.d3hl.site
OMNI_USER_EMAIL="d3tech@pm.me"
OMNI_USER_PASSWORD=op://d3HL/omni_env/OMNI_USER_PASSWORD