# OpenClaw Tracking Agent — Architecture (Reframed)

> **Previous approach (WRONG):** Build 7 separate plugin phases from scratch.
> **Correct approach:** OpenClaw is an existing agent platform. Tracking setup is a **skill + workspace config** that teaches the agent to use existing MCP servers via mcporter.

## The Core Insight

OpenClaw already has everything needed:
- **mcporter** — bridges MCP servers via CLI (`mcporter call gtm.list_tags`)
- **Skills system** — SKILL.md files that teach the agent workflows
- **Workspace config** — markdown files (SCOPE.md, TOOLS.md, etc.) that define operational context
- **Browser automation** — `src/browser/` for site crawling and verification
- **Memory system** — daily notes + curated long-term memory

We don't build a new runtime. We write a skill that orchestrates existing tools.

---

## Architecture: 3 Layers

### Layer 1: MCP Servers (Already Exist)

These are accessed via `mcporter call <server.tool>`:

| Server | Purpose | Tools |
|--------|---------|-------|
| `gtm` | Google Tag Manager API | list/create/update tags, triggers, variables, versions |
| `google-ads` | Google Ads reporting + config | campaigns, conversions, audiences, keywords |
| `stape` | Server-side GTM via Stape | containers, domains, power-ups, analytics |
| `meta` | Meta CAPI / Pixel | (future — via Pipeboard or direct) |

**mcporter config** (`config/mcporter.json`):
```json
{
  "servers": {
    "gtm": {
      "command": "npx",
      "args": ["@anthropic/gtm-mcp-server"],
      "env": { "GTM_ACCOUNT_ID": "{{account_id}}" }
    },
    "stape": {
      "command": "npx",
      "args": ["stape-mcp-server"],
      "env": { "STAPE_API_KEY": "{{stape_key}}" }
    }
  }
}
```

### Layer 2: Tracking Setup Skill (SKILL.md)

A single SKILL.md that teaches the agent the end-to-end tracking workflow:

```yaml
---
name: tracking-setup
description: Autonomous tracking implementation — crawl site, audit GTM, create plan, implement tags, verify firing.
metadata:
  openclaw:
    emoji: 📊
    requires:
      bins: [mcporter]
      skills: [mcporter]
    install:
      - id: gtm-mcp
        kind: node
        package: "@anthropic/gtm-mcp-server"
        label: "GTM MCP Server"
      - id: stape-mcp
        kind: node
        package: "stape-mcp-server"
        label: "Stape MCP Server"
---
```

**Skill workflow:**

1. **Discovery** — Use browser to crawl target site, identify pages, forms, CTAs, video players, scroll depth opportunities
2. **Audit** — `mcporter call gtm.list_tags` to read existing container, find gaps
3. **Plan** — Generate tracking plan from discovered actions + reference docs
4. **Implement** — `mcporter call gtm.create_tag` / `gtm.create_trigger` / `gtm.create_variable`
5. **Verify** — Use browser to load site with GTM preview, confirm tag firing via dataLayer
6. **Report** — Write implementation report to MEMORY.md, update STRATEGY-DESK.md

### Layer 3: Workspace Templates (Per-Client Config)

Pre-filled markdown files for tracking-focused deployments:

**SCOPE.md** — Tracking-specific phases:
- Phase 1: Foundation (GTM container access, MCP server auth, site crawl)
- Phase 2: Implementation (tags, triggers, variables, consent mode)
- Phase 3: Verification (preview mode testing, cross-browser checks)
- Phase 4: Monitoring (health checks, data quality alerts)

**TOOLS.md** — MCP server connection details:
- GTM Account ID, Container ID
- Stape container identifier
- Google Ads Customer ID, Login Customer ID
- Site URLs to crawl

**HEARTBEAT.md** — Scheduled monitoring:
- Daily: Check tag firing health via GTM debug
- Weekly: Review conversion data quality
- Monthly: Audit for new trackable surfaces

**STRATEGY-DESK.md** — Active tracking priorities:
- What tracking is being implemented
- Which platforms need configuration
- Open decisions (consent mode strategy, etc.)

---

## Repo Structure (New)

```
openclaw-tracking-setup/
├── skill/
│   └── SKILL.md                    # The tracking-setup skill for OpenClaw
├── mcporter-config/
│   └── tracking-servers.json       # MCP server configs for mcporter
├── workspace-templates/
│   ├── SCOPE.md                    # Pre-filled tracking deployment scope
│   ├── TOOLS.md                    # MCP connection details template
│   ├── HEARTBEAT.md                # Monitoring schedule
│   └── STRATEGY-DESK.md            # Tracking priorities template
├── tracking-references/            # Reference docs the agent reads
│   ├── gtm-tag-reference.md
│   ├── google-ads-tracking.md
│   ├── meta-capi-reference.md
│   └── stape-sgtm-reference.md
├── CLI-TOOLS/                      # Standalone CLI tools (existing)
│   └── google-ads/
├── README.md
└── CLAUDE.md
```

**Removed:** OPENCLAW-MASTER-PLAN.md, OPENCLAW-CLAUDE-CODE-PROMPTS.md (7-phase approach), plugin-marketplace/, sheepdog-core/, PLANNING/, PROMPTS/, AGENT-HANDOFF/

---

## How It Works End-to-End

1. **Operator deploys OpenClaw** to a client Mac Mini with workspace config files
2. **Operator installs tracking skill**: copies `skill/SKILL.md` to the workspace `skills/` directory
3. **Operator configures mcporter**: adds tracking MCP servers from `mcporter-config/tracking-servers.json`
4. **Operator fills workspace templates**: SCOPE.md, TOOLS.md with client-specific GTM/GA/Stape details
5. **Agent reads skill on session start**, sees tracking workflow instructions
6. **Agent executes autonomously**: crawls site → audits GTM → creates plan → implements → verifies
7. **Agent reports results** to MEMORY.md and updates STRATEGY-DESK.md

No custom runtime. No plugin builds. Just a well-written skill file and proper workspace config.

---

## What We Keep From Previous Work

| Asset | Status | New Location |
|-------|--------|-------------|
| tracking-references/*.md | ✅ Keep | Same path |
| CLI-TOOLS/google-ads/ | ✅ Keep | Same path (standalone tools) |
| OPENCLAW-MASTER-PLAN.md | ❌ Replace | This document |
| OPENCLAW-CLAUDE-CODE-PROMPTS.md | ❌ Replace | Single prompt below |
| plugin-marketplace/ | ❌ Remove | Not needed |
| sheepdog-core/ | ❌ Remove | Not needed |
| PLANNING/ | ❌ Remove | Absorbed into skill |
| PROMPTS/ | ❌ Remove | Absorbed into skill |
| AGENT-HANDOFF/ | ❌ Remove | Absorbed into workspace templates |
