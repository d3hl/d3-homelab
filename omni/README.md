# Deploy Omni
    - run start.sh to fetch latest keys and secrets
    - Run "docker compose up" 

# Troubleshoot
    - Clean git tree and pull again:  git clean -fd && git pull origin main
    - Manual export key: gpg --export-secret-key --armor d3tech@pm.me > omni.asc