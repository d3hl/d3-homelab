# ADR-001: IaC tool for d3-homelab — Terraform, OpenTofu, or Pulumi

**Status:** Proposed
**Date:** 2026-05-15
**Deciders:** d3

## Context

`d3-homelab` provisions a 4-node Proxmox VE cluster (CEPH storage, OVS VLANs) plus the Komodo control plane and Authentik. Today everything under `terraform/` is HCL, driven through `terraform plan` / `apply` with a `.tfvars` file for secrets, against the Telmate / `bpg` Proxmox provider. VMs are cloned from template `999`, never built from scratch, and Ansible takes over post-boot.

Three forces are pushing on the IaC tool choice now:

1. **HashiCorp's license change.** Terraform moved from MPL 2.0 to the Business Source License (BSL) at v1.6 (Aug 2023). For a personal homelab the license is harmless, but it permanently changes the upstream-governance story and rules out commercial OSS redistribution.
2. **GitOps fit.** The stated constraint is "prefer GitOps-friendly". Today the loop is local `terraform apply`; the longer-term direction is `git push` → GitHub Actions → plan/apply against the Proxmox cluster, with state stored centrally and PR-reviewable diffs.
3. **Provider depth for Proxmox.** Whichever tool wins has to keep working with the `bpg-proxmox` / Telmate provider ecosystem — the entire `terraform/pve` and `terraform/komodo` tree depends on it.

The Authentik tree already runs on a separate Terraform state, and Omni / Ansible are out of scope here — this ADR only governs `terraform/` going forward.

## Decision

Adopt **OpenTofu 1.8+** as the IaC tool for `d3-homelab`. Rename the directory from `terraform/` to `tofu/` (or alias via `.terraform-version` and the `tofu` CLI) and switch CI to `opentofu/setup-opentofu`. Keep the existing modules, providers (`bpg-proxmox`), and `.tfvars` workflow unchanged.

## Options considered

### Option A — Stay on Terraform (HashiCorp, BSL)

| Dimension | Assessment |
|---|---|
| Complexity | Low — already in use |
| Cost | $0 for personal use; BSL allows internal use indefinitely |
| Scalability | Mature; battle-tested |
| GitOps fit | Strong — HCL diffs cleanly in PRs, broad CI ecosystem |
| Team familiarity | Highest — all existing code is HCL |
| Ecosystem | Largest provider/module registry |
| Lock-in / governance | Single vendor (HashiCorp / IBM); BSL forbids competitive hosting; pace of feature delivery slowed post-license-change |

**Pros:** Zero migration cost. Registry parity. Familiar tooling.
**Cons:** BSL governance risk — terms can change again. Community has visibly forked away from it. Future-dated terraform features may land in OpenTofu first (already true for early-eval / static functions).

### Option B — Migrate to OpenTofu (Linux Foundation, MPL 2.0) — *recommended*

| Dimension | Assessment |
|---|---|
| Complexity | Very low — drop-in compatible up through Terraform 1.5 syntax |
| Cost | $0, MPL 2.0 |
| Scalability | Same engine lineage as Terraform; production-deployed at Oracle, GitLab, Cloudflare |
| GitOps fit | Strong — identical HCL, identical CI patterns, `opentofu/setup-opentofu` GH Action is first-class |
| Team familiarity | High — same HCL, same `init/plan/apply` verbs (just `tofu` instead of `terraform`) |
| Ecosystem | Uses the OpenTofu Registry; transparently proxies the Terraform Registry for providers — `bpg-proxmox`, `Telmate/proxmox`, etc. all available |
| Lock-in / governance | Linux Foundation–governed, open contribution model, no BSL clauses |

**Pros:** No code rewrite. Removes BSL-future risk. Adds features Terraform doesn't have yet (early variable/locals evaluation, `-exclude` planning, state encryption at-rest). GH Actions integration is a one-line swap. Self-hosted state backends (S3-compatible, Postgres) work unchanged.
**Cons:** Smaller (but growing) community. A handful of post-1.6 Terraform features are not yet in OpenTofu, and vice-versa — divergence will widen over time. Some commercial SaaS (Terraform Cloud) won't work; for a homelab this is irrelevant.

### Option C — Rewrite in Pulumi (Python or TypeScript)

| Dimension | Assessment |
|---|---|
| Complexity | High — full rewrite of `terraform/pve` and `terraform/komodo` modules |
| Cost | $0 for individual / OSS use; paid tiers above 500 resources |
| Scalability | Excellent for large, programmatically-generated infra |
| GitOps fit | Workable but heavier — code reviews read like program diffs, not config; `pulumi preview` output is less PR-friendly than `terraform plan` |
| Team familiarity | Adds a new language surface (Go/Python/TS) on top of HCL knowledge |
| Ecosystem | Wraps Terraform providers via the Pulumi Terraform Bridge — the `bpg-proxmox` integration works but lags upstream by a release or two |
| Lock-in / governance | Pulumi Cloud is the default state backend; self-hosted backend supported but less idiomatic |

**Pros:** Real loops, conditionals, and abstractions for repeated patterns (per-node Komodo VMs, dual-NIC topologies). Type safety in IDE. Good fit if the homelab grows toward dynamic VM fleets.
**Cons:** The win — real programming languages — is mostly wasted on a 4-node cluster with templated clones. Drift between Pulumi-generated state and the existing `terraform/` modules during any transition. PR diffs become harder to reason about for infrastructure reviewers.

## Trade-off analysis

The realistic competition here is A vs B; Pulumi is a different category of tool and the homelab's complexity doesn't justify its overhead.

Between Terraform and OpenTofu the differences for this project are narrow:

- **Migration cost:** `mv terraform/ tofu/`, swap one GitHub Action, done. Provider blocks (`bpg-proxmox`) work identically. State files are interchangeable up through the v1.5 schema.
- **GitOps:** Both are equally good. HCL is HCL. PR-driven plan/apply in GitHub Actions is a solved problem on both sides.
- **Risk of staying:** Low today, non-zero over a 3–5 year horizon. The 2023 license change was unilateral; nothing prevents another one.
- **Risk of moving:** Low — features the homelab actually uses (clone from template, cloud-init, dual NICs, datastore selection) are 100% supported. The risk is that OpenTofu adds a feature you start to depend on, making a future move back harder. This is the same lock-in shape, just pointed the other way.

OpenTofu wins because (a) the migration is effectively free, (b) it removes a license-driven governance risk you currently carry, and (c) it matches the project's other open-source-first, self-hosted choices (Proxmox over VMware, Authentik over Okta, Talos/Omni over managed K8s).

## Consequences

What becomes easier:

- Future CI changes — no Terraform-Cloud-only features creep in.
- Adopting state encryption at rest (OpenTofu 1.7+) without third-party tooling.
- Aligning with the broader self-hosted homelab ecosystem (most published examples are migrating to OpenTofu).

What becomes harder:

- Copy-pasting from new Terraform-only tutorials may occasionally hit a syntax mismatch — rare but possible.
- IDE / language-server tooling lag slightly behind Terraform's; the official VS Code extension for OpenTofu is solid but younger.
- Any future commercial vendor that integrates "Terraform Cloud" (e.g., env0 free tier, Spacelift) needs an OpenTofu-compatible backend — most already support both.

What we'll need to revisit:

- If the homelab grows to dozens of dynamically-generated VMs, reopen the Pulumi conversation — programmatic abstractions become genuinely useful past a threshold.
- If OpenTofu governance falters (Linux Foundation project, but still young), revisit going back to Terraform — drop-in compatibility cuts both ways.

## Action items

1. [ ] Install OpenTofu locally: `brew install opentofu` or download the 1.8+ binary.
2. [ ] In `terraform/komodo/` and `terraform/pve/`, run `tofu init -upgrade` and confirm a clean plan against the existing state.
3. [ ] Rename `terraform/` → `tofu/` (or leave the directory name and just swap the CLI; tooling doesn't care).
4. [ ] Update `CLAUDE.md` — replace `terraform init/plan/apply` with `tofu init/plan/apply`.
5. [ ] Add a GitHub Actions workflow (`.github/workflows/tofu.yml`) using `opentofu/setup-opentofu@v1` for PR plans and main-branch applies, with `TF_VAR_*` injection from GitHub secrets (or 1Password Connect, matching the Omni pattern).
6. [ ] Move state to a remote backend (S3-compatible — MinIO on the cluster, or Backblaze B2) so CI and local stay consistent.
7. [ ] Decide whether to enable OpenTofu state encryption now or defer until remote state is wired up.
8. [ ] Re-evaluate this ADR if the homelab grows past ~30 managed VMs, or if OpenTofu's roadmap diverges sharply from `bpg-proxmox` requirements.
