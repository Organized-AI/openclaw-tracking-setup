# Claude Code Prompt: OpenClaw Tracking Agent Skill

> **Run with:** `claude --dangerously-skip-permissions`
>
> **Environment Variables (for Claude Code Web):**
> ```
> GITHUB_TOKEN=<your-token>
> ```

---

## Prompt

```
You are restructuring the Organized-AI/openclaw-tracking-setup repository to reflect the correct architecture: OpenClaw is an EXISTING agent platform (https://github.com/openclaw/openclaw). The tracking setup is a SKILL that teaches the OpenClaw agent how to autonomously set up and verify tracking using MCP servers via mcporter.

### Context

OpenClaw uses:
- **Skills** (SKILL.md files) — teach the agent workflows
- **mcporter** — CLI bridge to MCP servers (`mcporter call gtm.list_tags`)
- **Workspace config** (SOUL.md, SCOPE.md, TOOLS.md, etc.) — per-client operational context
- **Browser automation** — for site crawling and verification

The MCP servers already exist:
- GTM MCP (Google Tag Manager API)
- Stape MCP (server-side GTM)
- Google Ads MCP (reporting + conversions)

### Task: Restructure the repo

**Step 1: Clone and clean**
```bash
cd /Users/supabowl/Library/Mobile\ Documents/com~apple~CloudDocs/BHT\ Promo\ iCloud/Organized\ AI/Windsurf
git clone https://github.com/organized-ai/openclaw-tracking-setup.git
cd openclaw-tracking-setup
```

Remove the old architecture files (keep tracking-references/ and CLI-TOOLS/):
- Delete: OPENCLAW-MASTER-PLAN.md, OPENCLAW-CLAUDE-CODE-PROMPTS.md
- Delete directories: plugin-marketplace/, sheepdog-core/, PLANNING/, PROMPTS/, AGENT-HANDOFF/

**Step 2: Create skill/ directory with SKILL.md**

Create `skill/SKILL.md` following the OpenClaw skill pattern (see skills/mcporter/SKILL.md in openclaw/openclaw for the format):

```yaml
---
name: tracking-setup
description: Autonomous tracking implementation — crawl site, audit GTM container, create tracking plan, implement tags/triggers/variables, verify firing, and monitor health. Uses mcporter to access GTM, Google Ads, and Stape MCP servers.
homepage: https://github.com/organized-ai/openclaw-tracking-setup
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

The body of SKILL.md should contain the full tracking workflow:

**Phase 1 — Discovery**
- Read TOOLS.md for target site URLs and GTM container details
- Use browser to crawl the site: identify pages, forms, CTAs, video embeds, scroll depth opportunities
- Document all trackable user actions in a discovery report
- Save to memory/YYYY-MM-DD.md

**Phase 2 — Audit**
- `mcporter call gtm.list_tags --output json` to read all existing tags
- `mcporter call gtm.list_triggers --output json` for triggers
- `mcporter call gtm.list_variables --output json` for variables
- Compare existing tracking vs. discovered actions
- Identify gaps, duplicates, misconfigured tags
- Reference tracking-references/*.md for best practices

**Phase 3 — Plan**
- Generate a tracking plan with:
  - Tags to create (name, type, trigger, firing rules)
  - Triggers to create (type, conditions)
  - Variables to create (type, value)
  - Consent mode configuration
  - Server-side forwarding rules (if Stape)
- Present plan for approval before implementing

**Phase 4 — Implement**
- Create variables first (dependencies):
  `mcporter call gtm.create_variable name="..." type="..." parameter='[...]'`
- Create triggers:
  `mcporter call gtm.create_trigger name="..." type="..." filter='[...]'`
- Create tags:
  `mcporter call gtm.create_tag name="..." type="..." firingTriggerId='[...]' parameter='[...]'`
- If Stape: configure server-side container, domains, power-ups
  `mcporter call stape.container_crud action=update ...`

**Phase 5 — Verify**
- Use browser to load target site with GTM preview mode enabled
- Check dataLayer for expected events
- Verify tag firing in GTM debug panel
- Cross-check conversion events in Google Ads / GA4 real-time reports
- Document any issues

**Phase 6 — Monitor (Ongoing via HEARTBEAT.md)**
- Daily: Quick health check — are conversion tags still firing?
- Weekly: Data quality review — are metrics within expected ranges?
- Monthly: Full re-crawl — any new pages/forms/CTAs added?

**Step 3: Create mcporter-config/ directory**

Create `mcporter-config/tracking-servers.json`:
```json
{
  "servers": {
    "gtm": {
      "command": "npx",
      "args": ["@anthropic/gtm-mcp-server"],
      "env": {
        "GTM_ACCOUNT_ID": "{{FILL: GTM Account ID}}",
        "GTM_OAUTH_CLIENT_ID": "{{FILL: OAuth Client ID}}",
        "GTM_OAUTH_CLIENT_SECRET": "{{FILL: OAuth Client Secret}}",
        "GTM_OAUTH_REFRESH_TOKEN": "{{FILL: OAuth Refresh Token}}"
      }
    },
    "stape": {
      "command": "npx",
      "args": ["stape-mcp-server"],
      "env": {
        "STAPE_API_KEY": "{{FILL: Stape API Key}}"
      }
    },
    "google-ads": {
      "command": "npx",
      "args": ["google-ads-mcp-server"],
      "env": {
        "GOOGLE_ADS_CUSTOMER_ID": "{{FILL: Customer ID}}",
        "GOOGLE_ADS_LOGIN_CUSTOMER_ID": "{{FILL: Login Customer ID}}",
        "GOOGLE_ADS_DEVELOPER_TOKEN": "{{FILL: Developer Token}}"
      }
    }
  }
}
```

**Step 4: Create workspace-templates/ directory**

Create pre-filled workspace templates for tracking deployments:

`workspace-templates/SCOPE.md` — 4 tracking phases:
- Phase 1: Foundation (GTM container access, MCP auth, initial site crawl)
- Phase 2: Implementation (tags, triggers, variables, consent mode, sGTM)
- Phase 3: Verification (preview mode testing, real-time data checks, cross-browser)
- Phase 4: Monitoring (daily health checks, weekly data quality, monthly re-audits)

`workspace-templates/TOOLS.md` — Template with placeholders:
- GTM Account/Container IDs
- Stape container identifier and API key
- Google Ads Customer/Login IDs
- Target site URLs
- mcporter config path

`workspace-templates/HEARTBEAT.md` — Monitoring schedule:
- Morning: Check yesterday's conversion data quality
- SANDBOX mode by default (read/report only, no auto-publish)

`workspace-templates/STRATEGY-DESK.md` — Tracking priorities template:
- Active priority: Current tracking implementation
- Open loops: Platforms pending setup
- Decisions being weighed: Consent strategy, sGTM migration

**Step 5: Update CLAUDE.md**

Replace existing CLAUDE.md with project context that reflects the new architecture:
- This is an OpenClaw skill for autonomous tracking setup
- Key directories: skill/, mcporter-config/, workspace-templates/, tracking-references/, CLI-TOOLS/
- Reference the tracking-setup skill workflow

**Step 6: Write new README.md**

Replace the existing README with:
- Title: "OpenClaw Tracking Setup Skill"
- Description: A skill that teaches OpenClaw agents to autonomously implement and verify tracking (GTM, Google Ads, Meta CAPI, Stape sGTM)
- Architecture diagram showing: OpenClaw Agent → mcporter → MCP Servers → Platforms
- Installation instructions (copy skill, configure mcporter, fill workspace templates)
- What's included (skill, mcporter config, workspace templates, reference docs, CLI tools)
- Link to openclaw/openclaw repo

**Step 7: Commit and push**

Commit with message: "refactor: reframe as OpenClaw skill + workspace config (not plugins)"
Push to origin main.
```

---

## Environment Variables for Claude Code Web

```
GITHUB_TOKEN=<your-github-pat>
```

## Which GitHub?

Push to: **https://github.com/organized-ai/openclaw-tracking-setup** (Organized AI org)
```
