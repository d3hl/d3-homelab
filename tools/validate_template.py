#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "proxmoxer>=2.0",
#   "requests",
#   "rich>=13.0",
# ]
# ///
"""Validate Proxmox VM template health and cloud-init configuration."""

import argparse
import os
import re
import sys

from proxmoxer import ProxmoxAPI
from rich.console import Console
from rich.table import Table
from rich import box

console = Console()

KNOWN_NODES = ["nodeA", "nodeB", "nodeD", "nodeF"]

# Required config keys and their expected values/patterns for a cloud-init template
REQUIRED_CONFIG = {
    "scsihw": ("virtio-scsi-pci", "virtio-scsi-single"),
    "ostype": ("l26",),
}
REQUIRED_KEYS = ["scsi0", "ide2", "serial0", "boot"]
CLOUD_INIT_KEYS = ["ciuser", "ipconfig0", "ide2"]


def _parse_host(raw: str) -> str:
    raw = re.sub(r"^https?://", "", raw)
    raw = re.sub(r":\d+/?$", "", raw)
    return raw.rstrip("/")


def connect() -> ProxmoxAPI:
    host = os.environ.get("PROXMOX_HOST", "")
    if not host:
        console.print("[bold red]Error:[/] PROXMOX_HOST is not set.")
        console.print("  export PROXMOX_HOST=10.10.10.10")
        console.print("  export PROXMOX_API_TOKEN='user@realm!tokenid=secret'")
        sys.exit(1)
    host = _parse_host(host)

    api_token = os.environ.get("PROXMOX_API_TOKEN", "")
    if api_token:
        user_part, rest = api_token.split("!", 1)
        token_name, token_value = rest.split("=", 1)
        return ProxmoxAPI(host, user=user_part, token_name=token_name, token_value=token_value, verify_ssl=False)

    user = os.environ.get("PROXMOX_USER", "root@pam")
    token_name = os.environ.get("PROXMOX_TOKEN_NAME", "")
    token_value = os.environ.get("PROXMOX_TOKEN_VALUE", "")
    password = os.environ.get("PROXMOX_PASSWORD", "")

    if token_name and token_value:
        return ProxmoxAPI(host, user=user, token_name=token_name, token_value=token_value, verify_ssl=False)
    if password:
        return ProxmoxAPI(host, user=user, password=password, verify_ssl=False)

    console.print("[bold red]Error:[/] No credentials found.")
    console.print("  Set PROXMOX_API_TOKEN or PROXMOX_TOKEN_NAME+PROXMOX_TOKEN_VALUE or PROXMOX_PASSWORD")
    sys.exit(1)


def find_template_node(prox: ProxmoxAPI, vmid: int, preferred: str | None) -> tuple[str, dict] | None:
    """Find which node hosts the template and return (node, config)."""
    candidates = [preferred] + KNOWN_NODES if preferred else KNOWN_NODES
    for node in dict.fromkeys(n for n in candidates if n):
        try:
            config = prox.nodes(node).qemu(vmid).config.get()
            return node, config
        except Exception:
            continue
    return None


def check(label: str, passed: bool, detail: str = "") -> bool:
    icon = "[green]PASS[/]" if passed else "[red]FAIL[/]"
    line = f"  {icon}  {label}"
    if detail:
        line += f"  [dim]{detail}[/dim]"
    console.print(line)
    return passed


def main():
    parser = argparse.ArgumentParser(description="Validate VM template configuration for cloud-init readiness")
    parser.add_argument("--template-id", type=int, default=999, help="Template VM ID (default: 999)")
    parser.add_argument("--node", default=None, help="Proxmox node (auto-detected if omitted)")
    args = parser.parse_args()

    prox = connect()

    console.rule(f"[bold]Template Validation — VM {args.template_id}[/]")

    result = find_template_node(prox, args.template_id, args.node)
    if not result:
        console.print(f"[bold red]Error:[/] VM {args.template_id} not found on any node.")
        console.print(f"  Searched: {', '.join(KNOWN_NODES)}")
        sys.exit(1)

    node, config = result
    console.print(f"  Found on node : [cyan]{node}[/]")
    console.print(f"  VM name       : [bold]{config.get('name', 'unknown')}[/]")
    console.print()

    all_passed = True

    # 1. Template flag
    is_template = bool(config.get("template", 0))
    all_passed &= check("template flag set", is_template, "config.template=1")

    # 2. SCSI controller
    scsihw = config.get("scsihw", "")
    scsihw_ok = scsihw in REQUIRED_CONFIG["scsihw"]
    all_passed &= check("virtio-scsi controller", scsihw_ok, f"scsihw={scsihw or '(not set)'}")

    # 3. OS type
    ostype = config.get("ostype", "")
    ostype_ok = ostype in REQUIRED_CONFIG["ostype"]
    all_passed &= check("Linux OS type (l26)", ostype_ok, f"ostype={ostype or '(not set)'}")

    # 4. Boot disk (scsi0)
    scsi0 = config.get("scsi0", "")
    all_passed &= check("boot disk present (scsi0)", bool(scsi0), scsi0[:60] if scsi0 else "(not set)")

    # 5. Cloud-init CD-ROM (ide2)
    ide2 = config.get("ide2", "")
    ide2_ok = "cloudinit" in ide2.lower() if ide2 else False
    all_passed &= check("cloud-init CD-ROM (ide2)", ide2_ok, ide2[:60] if ide2 else "(not set)")

    # 6. Serial console
    serial0 = config.get("serial0", "")
    serial_ok = "socket" in serial0.lower() if serial0 else False
    all_passed &= check("serial console (socket)", serial_ok, f"serial0={serial0 or '(not set)'}")

    # 7. Boot order includes scsi0
    boot = config.get("boot", "")
    boot_ok = "scsi0" in boot or "c" in boot  # legacy 'c' = first disk
    all_passed &= check("boot order references disk", boot_ok, f"boot={boot or '(not set)'}")

    # 8. QEMU guest agent enabled
    agent = config.get("agent", "")
    agent_ok = "1" in str(agent)
    all_passed &= check("QEMU guest agent enabled", agent_ok, f"agent={agent or '0'}")

    # 9. SSH key injected via cloud-init
    sshkeys = config.get("sshkeys", "")
    all_passed &= check("SSH key configured", bool(sshkeys), "(present)" if sshkeys else "(not set)")

    # 10. Memory sanity check (>= 512 MB)
    mem = config.get("memory", 0)
    mem_ok = int(mem) >= 512
    all_passed &= check("memory >= 512 MB", mem_ok, f"{mem} MB")

    console.print()

    # Raw config table for reference
    table = Table(title="Full Config", box=box.MINIMAL_DOUBLE_HEAD, show_header=True)
    table.add_column("Key", style="bold cyan", no_wrap=True)
    table.add_column("Value")

    skip_keys = {"digest"}
    for k, v in sorted(config.items()):
        if k in skip_keys:
            continue
        val = str(v)
        if len(val) > 80:
            val = val[:77] + "..."
        table.add_row(k, val)

    console.print(table)
    console.print()

    if all_passed:
        console.print("[bold green]Template is valid and ready for cloning.[/]")
    else:
        console.print("[bold red]Template has issues — fix the FAIL items above before cloning.[/]")
        sys.exit(1)


if __name__ == "__main__":
    main()
