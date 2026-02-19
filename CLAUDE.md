# OpenClaw Tracking Setup

## What This Is
An OpenClaw **skill** that teaches the agent how to autonomously set up, verify, and monitor tracking across GTM, Google Ads, and Meta Ads. This is NOT a standalone tool — it's a workflow that runs inside the [OpenClaw agent platform](https://github.com/openclaw/openclaw).

## Architecture
- **Skill:** `skill/SKILL.md` — 6-phase tracking workflow (Discovery → Audit → Plan → Implement → Verify → Monitor)
- **MCP Servers** (via mcporter): GTM MCP, Stape MCP
- **CLI Tools** (native): google-ads-cli (35 tools, full read+write), meta-ads-cli (full CRUD)
- **Workspace Templates:** Pre-filled SCOPE.md and TOOLS.md for tracking deployments

## Project Structure
```
skill/
└── SKILL.md                    # Core skill — full tracking workflow

mcporter-config/
└── tracking-servers.json       # MCP server definitions for mcporter

workspace-templates/
├── SCOPE.md                    # 4-phase workspace scope template
└── TOOLS.md                    # Tool config template with all CLI/MCP references

tracking-references/            # Best practice docs (GA4, GTM, consent mode, etc.)
```

## Tool Access

| Tool | Method | Capabilities |
|------|--------|-------------|
| GTM MCP | `mcporter call gtm.*` | Full CRUD: tags, triggers, variables, versions, publishing |
| Stape MCP | `mcporter call stape.*` | Server-side containers, domains, power-ups, analytics |
| google-ads-cli | Direct CLI | Full read+write: campaigns, ad groups, ads, keywords, conversion actions |
| meta-ads-cli | Direct CLI | Full CRUD: campaigns, ad sets, ads, creatives, insights, targeting |

## Skill Execution Order
1. Phase 1 — Discovery (crawl site, read TOOLS.md)
2. Phase 2 — Audit (GTM + Google Ads + Meta + Stape)
3. Phase 3 — Plan (generate tracking plan, get approval)
4. Phase 4 — Implement (variables → triggers → tags → conversions → CAPI)
5. Phase 5 — Verify (preview mode, cross-browser, real-time checks)
6. Phase 6 — Monitor (daily/weekly/monthly health checks)

## DO NOT
- Publish GTM containers without running pre-publish audit
- Modify Default Workspace directly (always create a new workspace)
- Deploy Meta Pixel without event_id for deduplication
- Run `enable-campaign` (Google Ads) or set status ACTIVE (Meta) without explicit human approval — these start real ad spend
- Skip the Phase 3 approval gate — always present the plan before implementing
- Skip verification steps between phases

## Safety Rules
- All new Google Ads campaigns created in PAUSED status
- All new Meta campaigns created in PAUSED status
- Google Ads budgets in micros ($50/day = 50,000,000)
- Meta budgets in cents ($50/day = 5,000)
- `remove-keyword` is permanent — confirm before running
- GTM publish requires pre-publish audit pass

## Verification Requirements
Before completing ANY task:
1. Describe verification approach first
2. Test MCP connectivity: `mcporter call gtm.list_tags`
3. Test CLI connectivity: `google-ads-cli list-campaigns` / `meta-ads-cli campaigns --account-id ACT_ID`
4. For GTM changes: run pre-publish audit
5. For deployments: verify in GTM Preview mode
6. Save reports to memory/
