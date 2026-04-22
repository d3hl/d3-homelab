OMNI_ACCOUNT_UUID="op://d3HL/omni_env/OMNI_ACCOUNT_UUID"
NAME=omni
OMNI_IMG_TAG="op://d3HL/omni_env/OMNI_IMG_TAG"
OMNI_DOMAIN_NAME="op://d3HL/omni_env/OMNI_DOMAIN_NAME"

# Bind addresses for various services
BIND_ADDR=0.0.0.0:443
MACHINE_API_BIND_ADDR=0.0.0.0:8090
K8S_PROXY_BIND_ADDR=0.0.0.0:8100
EVENT_SINK_PORT=8091

# Advertised URLs
ADVERTISED_API_URL="op://d3HL/omni_env/ADVERTISED_API_URL"
ADVERTISED_K8S_PROXY_URL="op://d3HL/omni_env/ADVERTISED_K8S_PROXY_URL"
SIDEROLINK_ADVERTISED_API_URL="op://d3HL/omni_env/SIDEROLINK_ADVERTISED_API_URL"

# WireGuard address
SIDEROLINK_WIREGUARD_ADVERTISED_ADDR=10.10.10.40:50180

# Path to SSL certificate and key
# Get cert for via Let's Encrypt DNS challenge:
# sudo certbot certonly --dns-cloudflare -d omni.domain.me
TLS_CERT="op://d3HL/omni_env/TLS_CERT"
TLS_KEY="op://d3HL/omni_env/TLS_KEY"

# Path to etcd data directory on host
ETCD_VOLUME_PATH=/etc/etcd

# Path to SQLite storage directory on host (NEW in v1.4.0 - REQUIRED)
# This consolidates Discovery service state, Audit logs, Machine logs, and Secondary resources
SQLITE_STORAGE_PATH=/home/d3/sqlite/

# Path to GPG key file (exported with: gpg --export-secret-key --armor)
ETCD_ENCRYPTION_KEY=/home/d3/d3-homelab/omni/omni.asc


INITIAL_USER_EMAILS=d3tech@pm.me

# -----------------------------------------------------------------------------
# Auth0
# -----------------------------------------------------------------------------
# 1. Create account at https://auth0.com
# 2. Create a Single Page Application
# 3. Configure callback URLs:
#    - Allowed Callback URLs: https://omni.vanillax.me:443/oidc/callback
#    - Allowed Logout URLs: https://omni.vanillax.me:443/
#    - Allowed Web Origins: https://omni.vanillax.me:443
# 4. Copy Domain and Client ID below

AUTH=--auth-auth0-enabled=true --auth-auth0-domain=YOUR_AUTH0_DOMAIN.us.auth0.com --auth-auth0-client-id=YOUR_AUTH0_CLIENT_ID
