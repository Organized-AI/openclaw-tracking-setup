# OpenClaw Plugin Suite — Master Implementation Plan

## Overview

Three autonomous builder plugins for tracking infrastructure deployment across Google Ads, Meta, and Google Tag Manager. Each plugin follows the Claude Code plugin pattern established in `gtm-ai-plugin` and includes OpenClaw workspace wrappers for persistent agent integration.

---

## Architecture Summary

```
openclaw-google-ads/          # Google Ads conversion tracking builder
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   └── google-ads-builder/
│       ├── SKILL.md           # Core skill: conversion actions, audiences, remarketing
│       └── references/
│           ├── conversion-types.md
│           ├── gaql-patterns.md
│           └── naming-conventions.md
├── agents/
│   └── google-ads-agent.md    # Autonomous agent definition
├── commands/
│   ├── gads-audit.md          # Audit existing conversion actions
│   ├── gads-deploy.md         # Deploy new conversion tracking
│   └── gads-status.md         # Check deployment status
├── hooks/
│   ├── hooks.json
│   ├── pre-deploy-validation.md
│   └── post-deploy-verification.md
├── templates/
│   ├── conversion-action.template.json
│   └── remarketing-audience.template.json
├── planning/
│   └── IMPLEMENTATION-MASTER-PLAN.md
├── openclaw/                   # OpenClaw workspace wrapper
│   ├── TOOLS.md               # MCP tool config for OpenClaw
│   ├── HEARTBEAT-ENTRIES.md   # Scheduled audit tasks
│   └── SCOPE-PHASE.md         # Tracking checklist phase
├── mcp-servers.json
├── install.sh
├── PLUGIN.md
└── README.md

openclaw-meta/                 # Meta Pixel + CAPI builder
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   └── meta-tracking-builder/
│       ├── SKILL.md           # Core skill: Pixel, CAPI, event dedup
│       └── references/
│           ├── standard-events.md
│           ├── capi-parameters.md
│           ├── deduplication-guide.md
│           └── naming-conventions.md
├── agents/
│   └── meta-tracking-agent.md
├── commands/
│   ├── meta-audit.md
│   ├── meta-deploy.md
│   ├── meta-test-events.md
│   └── meta-status.md
├── hooks/
│   ├── hooks.json
│   ├── pre-deploy-validation.md
│   ├── post-deploy-verification.md
│   └── event-dedup-check.md
├── templates/
│   ├── pixel-tag.template.json
│   ├── capi-client.template.json
│   └── event-mapping.template.json
├── planning/
│   └── IMPLEMENTATION-MASTER-PLAN.md
├── openclaw/
│   ├── TOOLS.md
│   ├── HEARTBEAT-ENTRIES.md
│   └── SCOPE-PHASE.md
├── mcp-servers.json
├── install.sh
├── PLUGIN.md
└── README.md

openclaw-gtm/                  # Enhanced GTM builder (extends gtm-ai-plugin)
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   └── gtm-enhanced-builder/
│       ├── SKILL.md           # Enhanced: multi-platform orchestration
│       └── references/
│           ├── tag-types.md
│           ├── trigger-patterns.md
│           ├── variable-types.md
│           ├── sgtm-correlation.md
│           └── naming-conventions.md
├── agents/
│   └── gtm-orchestrator-agent.md
├── commands/
│   ├── gtm-build.md           # Build full tracking config
│   ├── gtm-audit.md           # Container audit
│   ├── gtm-publish.md         # Version + publish
│   ├── gtm-rollback.md        # Revert to previous version
│   └── gtm-status.md          # Container status
├── hooks/
│   ├── hooks.json
│   ├── pre-publish-audit.md
│   ├── post-phase.md
│   ├── pre-phase.md
│   └── ascii-diagram-generator.md
├── templates/
│   ├── ga4-config.template.json
│   ├── phase-state.template.json
│   └── config.template.json
├── planning/
│   └── IMPLEMENTATION-MASTER-PLAN.md
├── openclaw/
│   ├── TOOLS.md
│   ├── HEARTBEAT-ENTRIES.md
│   └── SCOPE-PHASE.md
├── mcp-servers.json
├── install.sh
├── PLUGIN.md
└── README.md
```

---

## MCP Tool Inventory

### Plugin 1: openclaw-google-ads
| Tool | Source | Status |
|------|--------|--------|
| `google-ads-download-report` | Google Ads MCP | Connected |
| `list-accounts` | Google Ads MCP | Connected |

**GAQL Capabilities** (via download-report):
- Query `conversion_action` resources to audit existing conversions
- Query `campaign`, `ad_group`, `ad_group_ad` for performance data
- Query `customer` for account-level settings
- Query `remarketing_action` for audience configuration

**Limitation**: Google Ads MCP is read-only via GAQL. Conversion action CREATION requires the Google Ads API mutate endpoints. The plugin will generate the API payloads and provide `curl` commands or use the Google Ads API client library via CLI tool.

### Plugin 2: openclaw-meta
| Tool | Source | Status |
|------|--------|--------|
| Pipeboard Meta MCP | pipeboard.co | Not Connected |
| GTM MCP (for Pixel tags) | Stape | Connected |
| Stape MCP (for sGTM CAPI) | Stape | Connected |

**Architecture**: Dual-tracking — Client-side Pixel via GTM + Server-side CAPI via sGTM with shared `event_id` for deduplication.

### Plugin 3: openclaw-gtm
| Tool | Source | Status |
|------|--------|--------|
| `gtm_tag` | GTM MCP (Stape) | Connected |
| `gtm_trigger` | GTM MCP (Stape) | Connected |
| `gtm_variable` | GTM MCP (Stape) | Connected |
| `gtm_built_in_variable` | GTM MCP (Stape) | Connected |
| `gtm_folder` | GTM MCP (Stape) | Connected |
| `gtm_workspace` | GTM MCP (Stape) | Connected |
| `gtm_version` | GTM MCP (Stape) | Connected |
| `gtm_container` | GTM MCP (Stape) | Connected |
| `gtm_template` | GTM MCP (Stape) | Connected |
| `gtm_client` | GTM MCP (Stape) | Connected |
| `gtm_transformation` | GTM MCP (Stape) | Connected |
| `stape_container_crud` | Stape MCP | Connected |
| `stape_container_domains` | Stape MCP | Connected |
| `stape_container_power_ups` | Stape MCP | Connected |

---

## Phased Implementation Order

### Phase 0: Scaffold All Three Plugins
Create directory structures, plugin.json, mcp-servers.json, install.sh for all three plugins simultaneously.

### Phase 1: openclaw-gtm (Highest Priority)
GTM is the foundation — both Meta and Google Ads plugins depend on GTM for tag deployment. Build this first with full MCP tool coverage.

### Phase 2: openclaw-google-ads
Google Ads conversion tracking. Uses confirmed Google Ads MCP for auditing + generates deployment artifacts.

### Phase 3: openclaw-meta
Meta Pixel + CAPI. Requires Pipeboard Meta MCP connection. Uses GTM MCP for Pixel tags, Stape MCP for sGTM CAPI configuration.

### Phase 4: OpenClaw Workspace Wrappers
Create TOOLS.md entries, HEARTBEAT.md scheduled tasks, SCOPE.md phase definitions for all three plugins.

### Phase 5: Integration Testing
Cross-plugin orchestration testing. Validate that openclaw-gtm can deploy tags that openclaw-meta and openclaw-google-ads define.

---

## Claude Code Prompts

See individual prompt files:
- `PROMPTS/PHASE-0-SCAFFOLD.md`
- `PROMPTS/PHASE-1-GTM.md`
- `PROMPTS/PHASE-2-GOOGLE-ADS.md`
- `PROMPTS/PHASE-3-META.md`
- `PROMPTS/PHASE-4-OPENCLAW-WRAPPERS.md`
- `PROMPTS/PHASE-5-INTEGRATION.md`

---

## Environment Variables

```bash
# Required for all plugins
export STAPE_API_KEY="your-stape-api-key"

# Google Ads (already configured)
export GOOGLE_ADS_DEVELOPER_TOKEN="your-dev-token"
export GOOGLE_ADS_LOGIN_CUSTOMER_ID="your-login-cid"

# Meta (requires Pipeboard connection)
export META_ACCESS_TOKEN="your-meta-token"
export META_PIXEL_ID="your-pixel-id"

# GTM (via Stape OAuth)
# Handled by Stape MCP server authentication
```

---

*Generated: 2026-02-19*
*Project: sheepdog-movie / OpenClaw Plugin Suite*