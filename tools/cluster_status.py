#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "proxmoxer>=2.0",
#   "requests",
#   "rich>=13.0",
# ]
# ///
"""Proxmox cluster health metrics and node status."""

import argparse
import os
import re
import sys

from proxmoxer import ProxmoxAPI
from rich import box
from rich.console import Console
from rich.table import Table

console = Console()

KNOWN_NODES = ["nodeA", "nodeB", "nodeD", "nodeF"]


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


def fmt_bytes(b: int) -> str:
    for unit in ("B", "KB", "MB", "GB", "TB"):
        if b < 1024:
            return f"{b:.1f} {unit}"
        b /= 1024
    return f"{b:.1f} PB"


def fmt_uptime(seconds: int) -> str:
    d, s = divmod(int(seconds), 86400)
    h, s = divmod(s, 3600)
    m, _ = divmod(s, 60)
    parts = []
    if d:
        parts.append(f"{d}d")
    if h:
        parts.append(f"{h}h")
    parts.append(f"{m}m")
    return " ".join(parts)


def color_pct(pct: float, warn: float = 75, crit: float = 90) -> str:
    if pct >= crit:
        return "red"
    if pct >= warn:
        return "yellow"
    return "green"


def main():
    parser = argparse.ArgumentParser(description="Proxmox cluster status — node resources and storage overview")
    parser.parse_args()

    prox = connect()

    # Cluster quorum overview
    cluster_items = prox.cluster.status.get()
    cluster_info = next((i for i in cluster_items if i.get("type") == "cluster"), {})
    nodes_online = sum(1 for i in cluster_items if i.get("type") == "node" and i.get("online"))
    nodes_total = sum(1 for i in cluster_items if i.get("type") == "node")
    quorate = bool(cluster_info.get("quorate", 0))

    console.rule("[bold]Cluster Overview[/]")
    console.print(f"  Name    : [bold]{cluster_info.get('name', 'unknown')}[/]")
    q_color = "green" if quorate else "red"
    console.print(f"  Quorum  : [{q_color}]{'YES' if quorate else 'NO — CLUSTER AT RISK'}[/{q_color}]")
    console.print(f"  Nodes   : {nodes_online}/{nodes_total} online")
    console.print()

    # Node resource table
    resources = prox.cluster.resources.get(type="node")

    table = Table(title="Node Resources", box=box.ROUNDED)
    table.add_column("Node", style="bold cyan")
    table.add_column("Status", justify="center")
    table.add_column("CPU %", justify="right")
    table.add_column("Mem Used", justify="right")
    table.add_column("Mem Total", justify="right")
    table.add_column("Mem %", justify="right")
    table.add_column("Uptime", justify="right")

    for r in sorted(resources, key=lambda x: x.get("node", "")):
        status = r.get("status", "unknown")
        s_str = f"[green]{status}[/]" if status == "online" else f"[red]{status}[/]"

        cpu_pct = r.get("cpu", 0) * 100
        c_color = color_pct(cpu_pct, warn=60, crit=80)

        mem_used = r.get("mem", 0)
        mem_total = r.get("maxmem", 1)
        mem_pct = mem_used / mem_total * 100
        m_color = color_pct(mem_pct)

        table.add_row(
            r.get("node", "?"),
            s_str,
            f"[{c_color}]{cpu_pct:.1f}%[/{c_color}]",
            fmt_bytes(mem_used),
            fmt_bytes(mem_total),
            f"[{m_color}]{mem_pct:.1f}%[/{m_color}]",
            fmt_uptime(r.get("uptime", 0)),
        )

    console.print(table)

    # Storage overview (deduplicated — shared storage appears once per node)
    storage_resources = prox.cluster.resources.get(type="storage")
    if storage_resources:
        console.print()
        stg_table = Table(title="Storage", box=box.ROUNDED)
        stg_table.add_column("Storage", style="bold cyan")
        stg_table.add_column("Used", justify="right")
        stg_table.add_column("Total", justify="right")
        stg_table.add_column("Used %", justify="right")
        stg_table.add_column("Status", justify="center")

        seen: set[str] = set()
        for s in sorted(storage_resources, key=lambda x: x.get("storage", "")):
            key = s.get("storage", "")
            if key in seen:
                continue
            seen.add(key)

            used = s.get("disk", 0)
            total = s.get("maxdisk", 0)
            pct = (used / total * 100) if total > 0 else 0
            p_color = color_pct(pct)
            status = s.get("status", "unknown")
            s_str = f"[green]{status}[/]" if status == "available" else f"[red]{status}[/]"

            stg_table.add_row(
                key,
                fmt_bytes(used),
                fmt_bytes(total),
                f"[{p_color}]{pct:.1f}%[/{p_color}]",
                s_str,
            )

        console.print(stg_table)


if __name__ == "__main__":
    main()
