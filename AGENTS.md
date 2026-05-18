# AGENTS.md

Repository guidance for Codex agents working in `d3-homelab`.

## Documentation Lookup

Use the `ctx7` CLI to fetch current documentation whenever the user asks about a library, framework, SDK, API, CLI tool, or cloud service. This includes Terraform, Ansible, Proxmox providers, Packer, Docker Compose, Talos, Omni, cloud services, setup instructions, API syntax, provider configuration, migrations, and library-specific debugging.

Do not use Context7 for refactoring, writing scripts from scratch, debugging repository business logic, code review, or general programming concepts.

Workflow:

1. Resolve the library first unless the user provides a `/org/project` ID:
   `npx ctx7@latest library <name> "<user's full question>"`
2. Pick the best match by exact name, relevance, snippet count, source reputation, and benchmark score.
3. Fetch docs:
   `npx ctx7@latest docs <libraryId> "<user's full question>"`
4. Answer from the fetched docs.

Run Context7 CLI requests outside Codex's default sandbox. If a Context7 command fails with DNS, host resolution, or fetch errors, rerun it outside the sandbox. If it fails with quota errors, tell the user and suggest `npx ctx7@latest login` or setting `CONTEXT7_API_KEY`.

## Project Overview

`d3-homelab` is a homelab infrastructure-as-code repository for a Proxmox-based virtualized environment.

Main areas:

- `terraform/`: Terraform Cloud workspaces and modules for Proxmox, Komodo, AAP, and Talos-related infrastructure.
- `ansible/`: configuration management, Proxmox host tasks, server setup, network automation, and Komodo deployment.
- `packer/`: Ubuntu image/template build assets.
- `omni/`: Omni and Dex configuration using Docker Compose and 1Password-rendered templates.
- `tools/`: Python Proxmox and Ceph health/validation scripts.
- `docs/`: architecture decision records and supporting documentation.

## Infrastructure Assumptions

Verify these before changing behavior that depends on them:

- SSH public key path used by cloud-init: `/home/d3/.ssh/d3_tf.pub`
- VM disk datastore: `cephVM`
- Cloud-init snippets datastore: `cFS`
- Main infrastructure subnet: `10.10.10.x`
- Proxmox nodes in current Terraform provider config: `nodeA`, `nodeB`, `nodeD`, `nodeF`
- Primary runtime user: `d3`
- Ubuntu template VM ID: `999`
- Komodo endpoint in Terraform: `https://10.10.10.35:8120`
- Komodo cluster IP range documented in `CLAUDE.md`: `10.10.10.30-34`

## Secrets

Treat all secrets and rendered files carefully.

- Terraform secrets live in ignored `.tfvars` files or Terraform Cloud variables.
- Ansible secrets are encrypted with Ansible Vault; use `--ask-vault-pass` unless a vault password file is explicitly configured.
- Omni and Docker secrets are rendered from 1Password templates using `op inject`.
- Do not commit rendered secrets, tokens, certificates, private keys, or generated `.env` files.
- Do not print sensitive file contents in responses.

## Terraform

Run Terraform from a concrete root module directory, not from `terraform/modules/`.

Examples:

```bash
cd terraform/pve
terraform init
terraform plan -var-file="../../secrets.tfvars"
terraform apply -var-file="../../secrets.tfvars"
```

```bash
cd terraform/komodo
terraform init
terraform plan -var-file="../../secrets.tfvars"
terraform apply -var-file="../../secrets.tfvars"
```

Current Proxmox provider convention:

- Use `bpg/proxmox`.
- Prefer API token auth.
- Preserve the provider `ssh` block where file upload or VM/LXC operations need node SSH access.
- For Proxmox VMs that are started by Terraform, make sure a bootable disk is attached and use `stop_on_destroy = true` where needed.
- VMs are cloned from template VM ID `999`; do not build VMs from scratch unless explicitly requested.

Terraform Cloud is configured for organization `d3-org`, project `homelab`, with workspace names such as `pve` and `komodo`.

## Ansible

Run Ansible from `ansible/`.

Examples:

```bash
cd ansible
ansible-playbook -i inventory/hosts.ini playbooks/komodo.yml --ask-vault-pass
```

Notes:

- `ansible/ansible.cfg` sets `roles_path=roles`, `host_key_checking=false`, and `interpreter_python=/usr/bin/python3.13`.
- Existing inventory files include `inventory/hosts.ini`, `inventory/komodo.yaml`, AAP inventory examples, and templates.
- Komodo deployment uses the vendored role `ansible/roles/bpbradley.komodo/`.
- Control Komodo role behavior with `komodo_action: install|update|uninstall` where the role expects it.

## Omni

Omni runs from `omni/` with Docker Compose and Dex OIDC.

```bash
cd omni
./start.sh
docker compose up -d
```

`start.sh` renders `.tpl` files into runtime files using `op inject`. Keep templates tracked and rendered outputs untracked unless the repository already intentionally tracks a non-secret example.

## Tools

Python helper scripts live in `tools/`:

- `validate_template.py`
- `cluster_status.py`
- `check_ceph_health.py`
- `check_cluster_health.py`

Use `uv run tools/<script>.py --help` to inspect usage when available.

## Editing Conventions

- Keep edits scoped to the requested area.
- Prefer existing Terraform, Ansible, shell, and Python patterns over introducing new structure.
- Do not modify generated/rendered secrets.
- Do not run destructive infrastructure commands such as `terraform apply`, `terraform destroy`, `qm destroy`, or broad Ansible playbooks unless the user explicitly asks for execution.
- For validation, prefer non-destructive commands first: `terraform fmt`, `terraform validate`, `terraform plan`, `ansible-playbook --syntax-check`, and script `--help` or dry-run modes where supported.

