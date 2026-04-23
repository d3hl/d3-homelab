!/bin/bash
TARGET_ENV="d3hl" op inject -f -i ".env.tpl" -o ".env"
TARGET_ENV="d3hl" op inject -f -i "cloudflare.tpl" -o "cloudflare.ini"
TARGET_ENV="d3hl" op inject -f -i "./certs/omni.tpl" -o "./certs/omni.asc"
TARGET_ENV="d3hl" op inject -f -i "./certs/server-chain.pem.tpl" -o "./certs/server-chain.pem"
TARGET_ENV="d3hl" op inject -f -i "./certs/server-key.pem.tpl" -o "./certs/server-key.pem"