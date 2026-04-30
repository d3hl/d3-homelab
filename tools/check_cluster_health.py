#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "proxmoxer>=2.0",
#   "requests",
#   "rich>=13.0",
# ]
# ///
"""Comprehensive Proxmox cluster diagnostics — nodes, CEPH, VMs, storage."""

import argparse
import os
import re
import sys

from proxmoxer import ProxmoxAPI
from rich import box
from rich.console import Console
from rich.panel import Panel
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


def find_ceph_node(prox: ProxmoxAPI) -> str | None:
    for node in KNOWN_NODES:
        try:
            prox.nodes(node).ceph.status.get()
            return node
        except Exception:
            continue
    return None


def section_cluster(prox: ProxmoxAPI) -> bool:
    """Returns True if cluster is healthy."""
    cluster_items = prox.cluster.status.get()
    cluster_info = next((i for i in cluster_items if i.get("type") == "cluster"), {})
    nodes_online = sum(1 for i in cluster_items if i.get("type") == "node" and i.get("online"))
    nodes_total = sum(1 for i in cluster_items if i.get("type") == "node")
    quorate = bool(cluster_info.get("quorate", 0))

    q_color = "green" if quorate else "red"
    n_color = "green" if nodes_online == nodes_total else "red"

    console.rule("[bold]1. Cluster[/]")
    console.print(f"  Name    : [bold]{cluster_info.get('name', 'unknown')}[/]")
    console.print(f"  Quorum  : [{q_color}]{'HEALTHY' if quorate else 'NO QUORUM — CRITICAL'}[/{q_color}]")
    console.print(f"  Nodes   : [{n_color}]{nodes_online}/{nodes_total} online[/{n_color}]")
    console.print()

    return quorate and nodes_online == nodes_total


def section_nodes(prox: ProxmoxAPI):
    resources = prox.cluster.resources.get(type="node")

    table = Table(title="Node Resources", box=box.ROUNDED)
    table.add_column("Node", style="bold cyan")
    table.add_column("Status", justify="center")
    table.add_column("CPU %", justify="right")
    table.add_column("Mem %", justify="right")
    table.add_column("Mem Used", justify="right")
    table.add_column("Mem Total", justify="right")
    table.add_column("Uptime", justify="right")

    issues = []
    for r in sorted(resources, key=lambda x: x.get("node", "")):
        status = r.get("status", "unknown")
        s_str = f"[green]{status}[/]" if status == "online" else f"[red]{status}[/]"

        cpu_pct = r.get("cpu", 0) * 100
        c_color = color_pct(cpu_pct, warn=60, crit=80)

        mem_used = r.get("mem", 0)
        mem_total = r.get("maxmem", 1)
        mem_pct = mem_used / mem_total * 100
        m_color = color_pct(mem_pct)

        if status != "online":
            issues.append(f"Node [cyan]{r.get('node')}[/] is [red]{status}[/]")
        if cpu_pct >= 80:
            issues.append(f"Node [cyan]{r.get('node')}[/] CPU at [red]{cpu_pct:.0f}%[/]")
        if mem_pct >= 90:
            issues.append(f"Node [cyan]{r.get('node')}[/] memory at [red]{mem_pct:.0f}%[/]")

        table.add_row(
            r.get("node", "?"),
            s_str,
            f"[{c_color}]{cpu_pct:.1f}%[/{c_color}]",
            f"[{m_color}]{mem_pct:.1f}%[/{m_color}]",
            fmt_bytes(mem_used),
            fmt_bytes(mem_total),
            fmt_uptime(r.get("uptime", 0)),
        )

    console.rule("[bold]2. Nodes[/]")
    console.print(table)
    for issue in issues:
        console.print(f"  [yellow]WARN[/]  {issue}")
    if not issues:
        console.print("  [green]All nodes healthy[/]")
    console.print()


def section_ceph(prox: ProxmoxAPI):
    console.rule("[bold]3. CEPH[/]")
    node = find_ceph_node(prox)
    if not node:
        console.print("  [yellow]CEPH not detected on any node[/]")
        console.print()
        return

    status = prox.nodes(node).ceph.status.get()
    health = status.get("health", {})
    health_status = health.get("status", "UNKNOWN")
    h_color = {"HEALTH_OK": "green", "HEALTH_WARN": "yellow", "HEALTH_ERR": "red"}.get(health_status, "red")

    osdmap = status.get("osdmap", {})
    num_osds = osdmap.get("num_osds", 0)
    num_up = osdmap.get("num_up_osds", 0)
    num_in = osdmap.get("num_in_osds", 0)
    osd_color = "green" if num_up == num_osds else "red"

    pgmap = status.get("pgmap", {})
    bytes_used = pgmap.get("bytes_used", 0)
    bytes_total = pgmap.get("bytes_total", 0)
    usage_pct = (bytes_used / bytes_total * 100) if bytes_total > 0 else 0
    u_color = color_pct(usage_pct)

    console.print(f"  Status  : [{h_color}][bold]{health_status}[/bold][/{h_color}]")
    console.print(f"  OSDs    : [{osd_color}]{num_up}/{num_osds} up[/{osd_color}], {num_in}/{num_osds} in")
    console.print(f"  Usage   : [{u_color}]{fmt_bytes(bytes_used)} / {fmt_bytes(bytes_total)} ({usage_pct:.1f}%)[/{u_color}]")

    checks = health.get("checks", {})
    for check_id, check in checks.items():
        sev = check.get("severity", "UNKNOWN")
        msg = check.get("summary", {}).get("message", check_id)
        c = "yellow" if sev == "HEALTH_WARN" else "red"
        console.print(f"  [{c}]  ERR  {msg}[/{c}]")

    console.print()


def section_vms(prox: ProxmoxAPI):
    console.rule("[bold]4. Virtual Machines[/]")
    vms = prox.cluster.resources.get(type="vm")

    running = sum(1 for v in vms if v.get("status") == "running")
    stopped = sum(1 for v in vms if v.get("status") == "stopped")
    other = len(vms) - running - stopped

    console.print(f"  Total   : {len(vms)}  ([green]{running} running[/], [dim]{stopped} stopped[/dim]{f', [yellow]{other} other[/]' if other else ''})")

    problem_vms = [v for v in vms if v.get("status") not in ("running", "stopped")]
    for v in problem_vms:
        console.print(f"  [yellow]WARN[/]  VM [cyan]{v.get('name', v.get('vmid'))}[/] is [red]{v.get('status')}[/]")

    console.print()


def section_storage(prox: ProxmoxAPI):
    console.rule("[bold]5. Storage[/]")
    storage_resources = prox.cluster.resources.get(type="storage")

    table = Table(box=box.ROUNDED)
    table.add_column("Storage", style="bold cyan")
    table.add_column("Used", justify="right")
    table.add_column("Total", justify="right")
    table.add_column("Used %", justify="right")
    table.add_column("Status", justify="center")

    seen: set[str] = set()
    issues = []
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

        if pct >= 90:
            issues.append(f"Storage [cyan]{key}[/] at [red]{pct:.0f}%[/]")
        if status != "available":
            issues.append(f"Storage [cyan]{key}[/] is [red]{status}[/]")

        table.add_row(key, fmt_bytes(used), fmt_bytes(total), f"[{p_color}]{pct:.1f}%[/{p_color}]", s_str)

    console.print(table)
    for issue in issues:
        console.print(f"  [yellow]WARN[/]  {issue}")
    if not issues:
        console.print("  [green]All storage healthy[/]")
    console.print()


def main():
    parser = argparse.ArgumentParser(description="Comprehensive cluster diagnostics — nodes, CEPH, VMs, storage")
    parser.parse_args()

    prox = connect()

    console.print()
    console.print(Panel("[bold]Proxmox Cluster Diagnostics[/]", expand=False))
    console.print()

    issues_found = False

    cluster_ok = section_cluster(prox)
    if not cluster_ok:
        issues_found = True

    section_nodes(prox)
    section_ceph(prox)
    section_vms(prox)
    section_storage(prox)

    if issues_found:
        console.print(Panel("[bold red]Issues detected — review sections above[/]", expand=False))
    else:
        console.print(Panel("[bold green]Cluster looks healthy[/]", expand=False))


if __name__ == "__main__":
    main()
