# AAP 2.6 Containerized Installation - all-in-one on RHEL 10
#
# Usage (from inside the extracted AAP installer bundle):
#   ./setup.sh -i /path/to/this/aap.ini
#
# Passwords below use Ansible Vault — encrypt with:
#   ansible-vault encrypt_string '<value>' --name '<var>'

[automationgateway]
aap ansible_host=10.10.10.60

[automationcontroller]
aap ansible_host=10.10.10.60

[automationhub]
aap ansible_host=10.10.10.60

[automationedacontroller]
aap ansible_host=10.10.10.60

[database]
aap ansible_host=10.10.10.60

[all:vars]
ansible_user=d3
ansible_become=true
ansible_ssh_private_key_file=/home/d3/.ssh/d3ops
ansible_python_interpreter=/usr/bin/python3

# ── Registry ─────────────────────────────────────────────────────────────────
# Red Hat registry credentials (registry.redhat.io)
# Get from https://access.redhat.com/terms-based-registry/
registry_url='registry.redhat.io'
registry_username='op://d3HLPRV/Redhat Registry/username'
registry_password='op://d3HLPRV/Redhat Registry/password'

# ── Admin passwords ───────────────────────────────────────────────────────────
admin_password='op://d3HLPRV/AAP Gateway Admin/password'
automationhub_admin_password='op://d3HLPRV/AAP Hub Admin/password'

# ── Redis ─────────────────────────────────────────────────────────────────────
redis_mode=standalone

# ── Shared PostgreSQL connection (controller database) ───────────────────────
pg_host='10.10.10.60'
pg_port='5432'
pg_database='awx'
pg_username='awx'
pg_password='op://d3HLPRV/AAP Controller DB/password'
pg_sslmode='prefer'

# ── Hub PostgreSQL connection ─────────────────────────────────────────────────
automationhub_pg_host='10.10.10.60'
automationhub_pg_port=5432
automationhub_pg_database='automationhub'
automationhub_pg_username='automationhub'
automationhub_pg_password='op://d3HLPRV/AAP Hub DB/password'
automationhub_pg_sslmode='prefer'

# ── Gateway PostgreSQL connection ─────────────────────────────────────────────
automationgateway_pg_host='10.10.10.60'
automationgateway_pg_port=5432
automationgateway_pg_database='gateway'
automationgateway_pg_username='gateway'
automationgateway_pg_password='op://d3HLPRV/AAP Gateway DB/password'

# ── EDA PostgreSQL connection ─────────────────────────────────────────────────
automationedacontroller_pg_host='10.10.10.60'
automationedacontroller_pg_port=5432
automationedacontroller_pg_database='eda'
automationedacontroller_pg_username='eda'
automationedacontroller_pg_password='op://d3HLPRV/AAP EDA DB/password'

# ── TLS ───────────────────────────────────────────────────────────────────────
# Defaults to self-signed. Set paths to use your own certs.
# automationhub_ssl_cert=/path/to/hub.crt
# automationhub_ssl_key=/path/to/hub.key
# automationhub_disable_https=False
# automationhub_ssl_validate_certs=False

# ── Receptor / mesh ──────────────────────────────────────────────────────────
# receptor_listener_port=27199

# ── Optional: generate installer token for Authentik/Dex SSO later ──────────
# automationcontroller_extra_settings:
#   - setting: SOCIAL_AUTH_OIDC_KEY
#     value: 'aap'
