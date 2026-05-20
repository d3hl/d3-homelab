#!/usr/bin/env python3
"""Non-destructive preflight checks for the AAP deployment path."""

from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = ROOT / ".github" / "workflows" / "hcp-terraform-aap.yml"
PROVIDER = ROOT / "terraform" / "aap" / "provider.tf"
VARIABLES = ROOT / "terraform" / "aap" / "variables.tf"
VMS = ROOT / "terraform" / "aap" / "vms.tf"
README = ROOT / "terraform" / "aap" / "README.md"
GITIGNORE = ROOT / ".gitignore"
INVENTORY = ROOT / "ansible" / "inventory" / "inventory-growth.ini"
LOCAL_INVENTORY = "ansible/inventory/inventory-growth.local.ini"


failures: list[str] = []
warnings: list[str] = []


def read(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except FileNotFoundError:
        failures.append(f"missing required file: {path.relative_to(ROOT)}")
        return ""


def check(condition: bool, label: str, detail: str = "") -> None:
    if condition:
        print(f"PASS  {label}")
    else:
        failures.append(label if not detail else f"{label}: {detail}")
        print(f"FAIL  {label}")
        if detail:
            print(f"      {detail}")


def warn(condition: bool, label: str) -> None:
    if condition:
        warnings.append(label)
        print(f"WARN  {label}")


def git_ls_files(path: str) -> bool:
    result = subprocess.run(
        ["git", "ls-files", path],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        check=False,
    )
    return bool(result.stdout.strip())


def contains_literal_passwords(text: str) -> bool:
    safe_tokens = ("{{", "vault_", "op://", "<", "lookup(")
    for raw_line in text.splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        if "password" not in line.lower() or "=" not in line:
            continue
        value = line.split("=", 1)[1].strip().strip("'\"")
        if value and not any(token in value for token in safe_tokens):
            return True
    return False


def has_string_assignment(text: str, name: str, value: str) -> bool:
    pattern = rf"^\s*{re.escape(name)}\s*=\s*\"{re.escape(value)}\"\s*$"
    return re.search(pattern, text, re.MULTILINE) is not None


def has_default(text: str, value: str) -> bool:
    pattern = rf"^\s*default\s*=\s*{re.escape(value)}\s*$"
    return re.search(pattern, text, re.MULTILINE) is not None


def main() -> int:
    workflow = read(WORKFLOW)
    provider = read(PROVIDER)
    variables = read(VARIABLES)
    vms = read(VMS)
    readme = read(README)
    gitignore = read(GITIGNORE)
    inventory = read(INVENTORY)

    print("AAP deployment repo preflight")
    print()

    check(has_string_assignment(provider, "organization", "d3-org"), "HCP organization is d3-org")
    check(has_string_assignment(provider, "project", "homelab"), "HCP project is homelab")
    check(has_string_assignment(provider, "name", "aap-container"), "HCP workspace is aap-container")

    check("runs-on: self-hosted" in workflow, "AAP workflow uses self-hosted runner")
    check("TF_WORKSPACE: aap-container" in workflow, "AAP workflow targets aap-container")
    check("CONFIG_DIRECTORY: ./terraform/aap" in workflow, "AAP workflow uploads terraform/aap")
    check("TF_API_TOKEN" in workflow, "AAP workflow requires TF_API_TOKEN")
    check("github.event_name == 'pull_request'" in workflow, "PR runs are plan-only/speculative")
    check("github.event_name == 'workflow_dispatch'" in workflow, "manual dispatch is wired to apply")

    check(has_default(variables, '"nodeD"'), "default AAP node is nodeD")
    check(has_default(variables, '"10.10.10.60/24"'), "default AAP IP is 10.10.10.60/24")
    check(has_default(variables, "8"), "default AAP CPU is 8 cores")
    check(has_default(variables, "24576"), "default AAP memory is 24576 MiB")
    check(has_default(variables, "160"), "default AAP disk is 160 GiB")

    check(has_string_assignment(vms, "pool_id", "aap"), "AAP Proxmox pool is declared")
    check(has_string_assignment(vms, "name", "aap"), "AAP VM name is aap")
    warn("initialization" not in vms, "AAP VM has no explicit cloud-init initialization block")

    required_groups = [
        "[automationgateway]",
        "[automationcontroller]",
        "[automationhub]",
        "[automationeda]",
        "[database]",
    ]
    for group in required_groups:
        check(group in inventory, f"inventory includes {group}")
    check("ansible_connection=local" in inventory, "inventory uses local connection")
    check("bundle_install=true" in inventory, "inventory is configured for bundled install")
    check("/bundle" in inventory, "bundle_dir expects a bundle directory")
    check("aap.d3hl.site" in inventory, "inventory targets aap.d3hl.site")
    check(not contains_literal_passwords(inventory), "tracked growth inventory is secret-free")
    check(LOCAL_INVENTORY in gitignore, "local secret inventory is ignored")
    warn(git_ls_files(LOCAL_INVENTORY), "ignored local inventory is tracked unexpectedly")

    check("Manual `workflow_dispatch` creates and applies a run." in readme, "README matches manual apply behavior")

    print()
    if warnings:
        print("Warnings:")
        for item in warnings:
            print(f"- {item}")
        print()

    if failures:
        print("Failures:")
        for item in failures:
            print(f"- {item}")
        return 1

    print("All blocking preflight checks passed.")
    print("External checks remain: GitHub secret, HCP workspace variables, runner status, and Proxmox reachability.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
