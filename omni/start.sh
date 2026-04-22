TARGET_ENV="d3hl" op inject -f -i ".env.tpl" -o ".env"
TARGET_ENV="d3hl" op inject -f -i "cloudflare.tpl" -o "cloudflare.ini"
TARGET_ENV="d3hl" op inject -f -i "omni.tpl" -o "omni.asc"