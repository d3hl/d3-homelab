#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "proxmoxer>=2.0",
#   "requests",
#   "rich>=13.0",
# ]
# ///
"""CEPH storage pool health monitoring via Proxmox API."""

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


def color_pct(pct: float, warn: float = 75, crit: float = 90) -> str:
    if pct >= crit:
        return "red"
    if pct >= warn:
        return "yellow"
    return "green"


def find_ceph_node(prox: ProxmoxAPI, preferred: str | None) -> str | None:
    """Return the first online node that has CEPH running."""
    candidates = [preferred] + KNOWN_NODES if preferred else KNOWN_NODES
    for node in dict.fromkeys(candidates):  # deduplicate, preserve order
        if not node:
            continue
        try:
            prox.nodes(node).ceph.status.get()
            return node
        except Exception:
            continue
    return None


def main():
    parser = argparse.ArgumentParser(description="CEPH health — OSDs, pools, monitors")
    parser.add_argument("--node", default=None, help="Proxmox node to query CEPH from (auto-detected if omitted)")
    args = parser.parse_args()

    prox = connect()

    node = find_ceph_node(prox, args.node)
    if not node:
        console.print("[bold red]Error:[/] No CEPH-capable node found. Is CEPH installed?")
        sys.exit(1)

    console.print(f"[dim]Querying CEPH via node:[/] [cyan]{node}[/]\n")

    # Overall health
    status = prox.nodes(node).ceph.status.get()
    health = status.get("health", {})
    health_status = health.get("status", "UNKNOWN")

    health_color = {"HEALTH_OK": "green", "HEALTH_WARN": "yellow", "HEALTH_ERR": "red"}.get(health_status, "red")

    console.rule("[bold]CEPH Health[/]")
    console.print(f"  Status  : [{health_color}][bold]{health_status}[/bold][/{health_color}]")

    checks = health.get("checks", {})
    if checks:
        for check_id, check in checks.items():
            sev = check.get("severity", "UNKNOWN")
            msg = check.get("summary", {}).get("message", check_id)
            c = "yellow" if sev == "HEALTH_WARN" else "red"
            console.print(f"  [{c}]  WARN  {msg}[/{c}]")

    # OSD map summary
    osdmap = status.get("osdmap", {})
    num_osds = osdmap.get("num_osds", 0)
    num_up = osdmap.get("num_up_osds", 0)
    num_in = osdmap.get("num_in_osds", 0)
    osd_color = "green" if num_up == num_osds else "red"

    console.print()
    console.print(f"  OSDs    : [{osd_color}]{num_up}/{num_osds} up[/{osd_color}], {num_in}/{num_osds} in")

    # PG map
    pgmap = status.get("pgmap", {})
    num_pgs = pgmap.get("num_pgs", 0)
    bytes_used = pgmap.get("bytes_used", 0)
    bytes_total = pgmap.get("bytes_total", 0)
    bytes_avail = pgmap.get("bytes_avail", 0)
    usage_pct = (bytes_used / bytes_total * 100) if bytes_total > 0 else 0
    pg_color = color_pct(usage_pct)

    console.print(f"  PGs     : {num_pgs}")
    console.print(f"  Usage   : [{pg_color}]{fmt_bytes(bytes_used)} / {fmt_bytes(bytes_total)} ({usage_pct:.1f}%)[/{pg_color}]")
    console.print(f"  Avail   : {fmt_bytes(bytes_avail)}")

    # Monitor status
    try:
        mons = prox.nodes(node).ceph.mon.get()
        console.print()
        mon_table = Table(title="Monitors", box=box.ROUNDED)
        mon_table.add_column("Name", style="bold cyan")
        mon_table.add_column("Host", justify="left")
        mon_table.add_column("Rank", justify="right")
        mon_table.add_column("In Quorum", justify="center")

        for m in sorted(mons, key=lambda x: x.get("name", "")):
            in_q = bool(m.get("quorum", 0))
            q_str = "[green]YES[/]" if in_q else "[red]NO[/]"
            mon_table.add_row(
                m.get("name", "?"),
                m.get("addr", "?").split(":")[0],
                str(m.get("rank", "?")),
                q_str,
            )
        console.print(mon_table)
    except Exception:
        pass

    # Pool usage
    try:
        pools = prox.nodes(node).ceph.pools.get()
        if pools:
            console.print()
            pool_table = Table(title="Pools", box=box.ROUNDED)
            pool_table.add_column("Pool", style="bold cyan")
            pool_table.add_column("Size", justify="right")
            pool_table.add_column("Used", justify="right")
            pool_table.add_column("Objects", justify="right")
            pool_table.add_column("PGs", justify="right")
            pool_table.add_column("Health", justify="center")

            for p in sorted(pools, key=lambda x: x.get("pool_name", "")):
                used = p.get("bytes_used", 0)
                obj_count = p.get("objects", 0)
                pg_num = p.get("pg_num", 0)
                size = p.get("size", 0)
                health = p.get("health", "ok")
                h_color = "green" if health == "ok" else "red"

                pool_table.add_row(
                    p.get("pool_name", "?"),
                    str(size),
                    fmt_bytes(used),
                    str(obj_count),
                    str(pg_num),
                    f"[{h_color}]{health}[/{h_color}]",
                )
            console.print(pool_table)
    except Exception:
        pass

    # OSD detail table
    try:
        osd_data = prox.nodes(node).ceph.osd.get()
        osd_nodes = osd_data.get("nodes", []) if isinstance(osd_data, dict) else osd_data

        if osd_nodes:
            console.print()
            osd_table = Table(title="OSDs", box=box.ROUNDED)
            osd_table.add_column("OSD", style="bold cyan")
            osd_table.add_column("Host", justify="left")
            osd_table.add_column("Status", justify="center")
            osd_table.add_column("In", justify="center")
            osd_table.add_column("Used", justify="right")
            osd_table.add_column("Total", justify="right")
            osd_table.add_column("Used %", justify="right")

            for osd in sorted(osd_nodes, key=lambda x: x.get("id", 0)):
                osd_status = osd.get("status", "unknown")
                s_color = "green" if osd_status == "up" else "red"
                in_cluster = bool(osd.get("in", 0))
                in_str = "[green]YES[/]" if in_cluster else "[red]NO[/]"

                kb_used = osd.get("kb_used", 0) * 1024
                kb_total = osd.get("kb", 0) * 1024
                pct = (kb_used / kb_total * 100) if kb_total > 0 else 0
                p_color = color_pct(pct)

                osd_table.add_row(
                    f"osd.{osd.get('id', '?')}",
                    osd.get("host", "?"),
                    f"[{s_color}]{osd_status}[/{s_color}]",
                    in_str,
                    fmt_bytes(kb_used),
                    fmt_bytes(kb_total),
                    f"[{p_color}]{pct:.1f}%[/{p_color}]",
                )
            console.print(osd_table)
    except Exception:
        pass


if __name__ == "__main__":
    main()
