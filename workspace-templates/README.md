# OpenClaw Tracking Setup — Workspace Template

**What this is:** A complete set of workspace documents for deploying the OpenClaw tracking agent to a new client. Copy the `workspace-templates/` directory to the client's OpenClaw workspace, then customize each file with the client's specifics.

## File Structure & Purpose

| File | Purpose | When to Customize |
|------|---------|-------------------|
| `AGENTS.md` | Agent behavior rules, safety defaults, approval gates | Rarely — core safety rules stay the same |
| `BOOTSTRAP.md` | First-run setup: gather client context, verify tools, begin discovery | Rarely — guides the agent's first session |
| `BOOT.md` | Session startup: connectivity checks, context load, status report | After TOOLS.md is configured with account IDs |
| `IDENTITY.md` | Agent identity (name, emoji) | During first conversation |
| `SOUL.md` | Agent personality, tracking-specific boundaries | Customize vibe per client preference |
| `USER.md` | Client business info, conversion actions, ad platform context, compliance | **Always** — 100% client-specific |
| `TOOLS.md` | Account IDs, container IDs, CLI paths, MCP config | **Always** — environment-specific |
| `SCOPE.md` | 4-phase workspace scope with entry/exit criteria | Rarely — standard tracking phases |
| `STRATEGY-DESK.md` | Current phase, active priorities, blocking issues, decisions | **Always** — updated every session |
| `HEARTBEAT.md` | Automated health checks (daily, weekly, monthly, quarterly) | Customize schedule per client timezone |
| `MEMORY.md` | Long-term tracking context (starts with structure, agent fills in) | Agent populates over time |

## Setup Workflow

### 1. Copy workspace templates
```bash
cp workspace-templates/* /path/to/client/openclaw/workspace/
```

### 2. Fill in client-specific files (in this order)

1. **USER.md** — Business type, conversion actions, ad platform context, compliance requirements
2. **TOOLS.md** — GTM container ID, Google Ads customer ID, Meta ad account ID, CLI paths, mcporter config
3. **STRATEGY-DESK.md** — Set initial phase to "Phase 1 — Discovery"
4. **HEARTBEAT.md** — Set timezone and alert preferences

### 3. Configure tool authentication

Ensure these are authenticated before first run:
- `mcporter` with GTM MCP and Stape MCP servers (see `mcporter-config/tracking-servers.json`)
- `google-ads-cli` with client's Google Ads account
- `meta-ads-cli` with client's Meta ad account

### 4. First run

Leave `BOOTSTRAP.md` intact. The agent will:
1. Introduce itself
2. Verify tool connectivity
3. Gather any missing client context
4. Set its identity in `IDENTITY.md`
5. Begin Phase 1 Discovery
6. Delete `BOOTSTRAP.md`

### 5. Ongoing

The agent follows the 6-phase workflow from `skill/SKILL.md`:
1. **Discovery** → Crawl site, identify trackable elements
2. **Audit** → Assess existing tracking, find gaps
3. **Plan** → Generate tracking plan (requires human approval)
4. **Implement** → Build tags, triggers, variables, conversion actions
5. **Verify** → Test in preview mode, cross-browser, real-time checks
6. **Monitor** → Ongoing health checks per HEARTBEAT.md

## Reference Documentation

The agent references `tracking-references/*.md` during planning and implementation:

| File | Domain Knowledge |
|------|-----------------|
| `Tracking-Architectures.md` | Pre-built blueprints per business type |
| `GA4-Event-Taxonomy.md` | Correct event names and parameters |
| `Meta-CAPI-Events.md` | CAPI event specs, user data, deduplication |
| `Google-Ads-Conversions.md` | Conversion action configuration rules |
| `Validation-Checklists.md` | Phase-gate verification checklists |
| `GTM-Naming-Conventions.md` | Consistent entity naming rules |
| `Common-Mistakes.md` | "Don't do this" error prevention |
| `GA4-Ecommerce-DataLayer.md` | JSON schemas for ecommerce events |
| `Consent-Mode-Implementation.md` | Consent Mode v2 implementation |
| `GTM-Tag-Patterns.md` | MCP API tag parameter templates |
| `GTM-Trigger-Patterns.md` | MCP API trigger parameter templates |
| `GTM-Variable-Patterns.md` | MCP API variable parameter templates |
| `sGTM-Architecture.md` | Server-side GTM data flow and configuration |
| `MCP-API-Reference.md` | Full MCP parameter schemas and error handling |

## Safety Notes

- All new Google Ads campaigns default to **PAUSED**
- All new Meta campaigns default to **PAUSED**
- GTM publishing requires pre-publish audit + human approval
- The agent will NEVER enable campaigns or start ad spend without explicit human approval
- Google Ads budgets in micros ($50/day = 50,000,000)
- Meta budgets in cents ($50/day = 5,000)
