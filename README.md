# OpenClaw Plugin Suite

**Three autonomous Claude Code plugins that deploy full-stack tracking infrastructure — GTM, Google Ads, and Meta — using MCP tools instead of manual UI clicks.**

[![Built with Claude Code](https://img.shields.io/badge/Built%20with-Claude%20Code-blueviolet)](https://claude.ai/claude-code)
[![Organized AI](https://img.shields.io/badge/Organized-AI-blue)](https://github.com/organized-ai)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## What is OpenClaw?

OpenClaw turns tracking infrastructure deployment into a conversation. Instead of clicking through GTM, Google Ads, and Meta Business Manager UIs, you run a Claude Code plugin that builds your entire tracking stack through MCP server APIs.

Each plugin follows the same pattern: **skill** (knowledge) → **agent** (autonomy) → **command** (execution) → **hook** (safety). Combined with Bowser browser automation for discovery and QA, OpenClaw handles the full lifecycle from site crawl to conversion verification.

### The Three Plugins

| Plugin | What It Builds | MCP Tools Used |
|--------|---------------|----------------|
| `openclaw-gtm` | Tags, triggers, variables, sGTM clients, consent mode, container versioning | GTM MCP (Stape), Stape MCP |
| `openclaw-google-ads` | Conversion actions, remarketing audiences, GAQL audit queries | Google Ads MCP |
| `openclaw-meta` | Pixel tags, CAPI server events, event deduplication, CAPIG gateway | GTM MCP, Stape MCP, Pipeboard Meta MCP |

### The Browser Layer (Bowser)

Phase 6 adds browser automation for tasks that require eyes on the page:

| Agent | Browser Engine | Purpose |
|-------|---------------|---------|
| Discovery Agent | Playwright (headless) | Crawl pages, classify elements, identify tracking opportunities |
| Preview Agent | Chrome MCP (observable) | Validate GTM Preview mode, inspect dataLayer, verify tag firing |
| QA Agent | Either | Run declarative YAML test stories against live conversions |

---

## Repository Structure

```
openclaw-tracking-setup/
├── .claude/                          # Claude Code configuration
├── CLAUDE.md                         # Project instructions for Claude
├── OPENCLAW-MASTER-PLAN.md           # Architecture & MCP tool inventory
├── OPENCLAW-CLAUDE-CODE-PROMPTS.md   # All 7 phase prompts (copy-paste ready)
│
├── PLANNING/
│   └── BOWSER-OPENCLAW-INTEGRATION-PLAN.md  # Browser automation integration plan
│
├── PROMPTS/                          # Individual phase prompt files
│   ├── PHASE-0-SCAFFOLD.md           # Directory structure + plugin.json
│   ├── PHASE-1-GTM.md               # GTM plugin (sGTM three-client pattern)
│   ├── PHASE-2-GOOGLE-ADS.md        # Google Ads plugin (GAQL + conversions)
│   ├── PHASE-3-META.md              # Meta plugin (CAPIG + dual-tracking)
│   ├── PHASE-4-OPENCLAW-WRAPPERS.md # Cross-platform orchestration
│   └── PHASE-5-INTEGRATION.md       # End-to-end testing
│
├── tracking-references/              # Platform-specific implementation patterns
│   ├── capig-setup-reference.md      # Meta CAPI Gateway (CAPIG) setup
│   ├── cross-platform-event-mapping.md # GA4 ↔ Meta ↔ Google Ads event mapping
│   ├── dual-tracking-linkedin-reference.md # LinkedIn client + server dual-tracking
│   └── sgtm-client-patterns.md       # sGTM three-client architecture
│
├── plugin-marketplace/               # Plugin output directories (built by phases)
│   ├── openclaw-gtm/
│   ├── openclaw-google-ads/
│   └── openclaw-meta/
│
├── sheepdog-core/                    # Reference codebase from live client project
└── AGENT-HANDOFF/                    # Cross-session context persistence
```

---

## How It Works

### Phased Execution

Each phase has a self-contained Claude Code prompt. You copy-paste the prompt, Claude Code builds the plugin autonomously.

| Phase | Name | Dependency | What Gets Built |
|-------|------|------------|-----------------|
| 0 | Scaffold | None | All 3 plugin directories, plugin.json, mcp-servers.json, install.sh |
| 1 | GTM | Phase 0 | `openclaw-gtm` — tags, triggers, variables, sGTM clients, consent mode |
| 2 | Google Ads | Phase 0 | `openclaw-google-ads` — conversion actions, audiences, GAQL patterns |
| 3 | Meta | Phase 0 | `openclaw-meta` — Pixel, CAPI, dedup, CAPIG gateway config |
| 4 | Wrappers | Phases 1-3 | OpenClaw workspace integration (TOOLS.md, HEARTBEAT, SCOPE) |
| 5 | Integration | Phase 4 | Cross-plugin orchestration testing |
| 6 | Bowser | Phase 0 | Browser automation — discovery, GTM Preview, conversion QA |

### Key Patterns

**sGTM Three-Client Architecture** — Every server-side container uses three specialized clients: GA4 Client (handles measurement protocol), Webhook Client (receives CAPI events), and Data Client (custom API ingestion). This pattern ensures clean data routing without cross-contamination.

**CAPIG (Conversions API Gateway)** — Meta's server-to-server integration that bypasses the browser entirely. OpenClaw configures the gateway, maps standard events, and sets up `event_id` deduplication between Pixel and CAPI.

**Dual-Tracking with Deduplication** — Client-side tags fire alongside server-side events. A shared `event_id` parameter ensures platforms count each conversion once. OpenClaw automates the dedup configuration across GTM and sGTM.

**Bowser Discovery → GTM Build Pipeline** — The Discovery Agent crawls a site and outputs a YAML report of tracking opportunities (buttons, forms, video players, scroll depth targets). This feeds directly into `openclaw-gtm` commands that create the corresponding tags and triggers.

---

## Quick Start

### Prerequisites

- [Claude Code](https://claude.ai/claude-code) installed
- MCP servers configured: GTM MCP (Stape), Google Ads MCP, Stape MCP
- Access to target GTM container and ad platform accounts

### Environment Variables

```bash
# Required for all plugins
export STAPE_API_KEY="your-stape-api-key"

# Google Ads
export GOOGLE_ADS_DEVELOPER_TOKEN="your-dev-token"
export GOOGLE_ADS_LOGIN_CUSTOMER_ID="your-login-cid"

# Meta (requires Pipeboard connection)
export META_ACCESS_TOKEN="your-meta-token"
export META_PIXEL_ID="your-pixel-id"

# Bowser (Phase 6)
export PLAYWRIGHT_MCP_VIEWPORT_SIZE=1440x900
```

### Build the Plugins

```bash
# Clone the repo
git clone https://github.com/Organized-AI/openclaw-tracking-setup.git
cd openclaw-tracking-setup

# Start with Phase 0 — scaffolds all three plugins
claude --dangerously-skip-permissions
# Paste the Phase 0 prompt from OPENCLAW-CLAUDE-CODE-PROMPTS.md

# Then run phases 1-6 sequentially (or Phase 6 in parallel after Phase 0)
```

---

## MCP Tool Coverage

### Connected Tools

| MCP Server | Tools Available | Used By |
|------------|----------------|---------|
| **GTM MCP (Stape)** | `gtm_tag`, `gtm_trigger`, `gtm_variable`, `gtm_workspace`, `gtm_version`, `gtm_container`, `gtm_template`, `gtm_client`, `gtm_transformation`, `gtm_built_in_variable`, `gtm_folder` | openclaw-gtm, openclaw-meta |
| **Stape MCP** | `stape_container_crud`, `stape_container_domains`, `stape_container_power_ups`, `stape_container_analytics`, `stape_container_statistics` | openclaw-gtm, openclaw-meta |
| **Google Ads MCP** | `google-ads-download-report`, `list-accounts` | openclaw-google-ads |
| **Chrome MCP** | `read_page`, `read_network_requests`, `read_console_messages`, `javascript_tool`, `navigate`, `find`, `computer` | Bowser Preview Agent |

### Tracking Endpoint Registry

The QA agent monitors network requests for these platform endpoints:

| Platform | Endpoint Pattern | Key Parameters |
|----------|-----------------|----------------|
| GA4 | `google-analytics.com/g/collect` | `en`, `ep.*`, `tid` |
| Google Ads | `googleads.g.doubleclick.net/pagead/conversion` | `label`, `value` |
| Meta Pixel | `facebook.com/tr` | `ev`, `id`, `cd` |
| Meta CAPI | `graph.facebook.com/v*/*/events` | `event_name`, `event_id` |
| LinkedIn | `px.ads.linkedin.com/collect` | `conversionId`, `li_fat_id` |
| TikTok | `analytics.tiktok.com/api/v*/pixel/track` | `event`, `pixel_code` |
| Snapchat | `tr.snapchat.com/p` | `e_event`, `pid` |

---

## Tracking References

The `tracking-references/` directory contains implementation patterns extracted from production client deployments:

- **CAPIG Setup Reference** — Step-by-step Meta Conversions API Gateway configuration
- **Cross-Platform Event Mapping** — How GA4 `purchase` maps to Meta `Purchase` maps to Google Ads `conversion` (with parameter mapping)
- **Dual-Tracking LinkedIn** — Client-side Insight Tag + server-side CAPI with `li_fat_id` passthrough
- **sGTM Client Patterns** — The three-client architecture for clean server-side data routing

---

## Project Status

| Component | Status |
|-----------|--------|
| Repository & Structure | ✅ Complete |
| Master Plan | ✅ Complete |
| Tracking References (4 docs) | ✅ Complete |
| Phase Prompts (0-5) | ✅ Complete |
| Phase 6 Bowser Integration Plan | ✅ Complete |
| Claude Code Prompts (all 7 phases) | ✅ Complete |
| Plugin Build (Phases 0-6) | 🔲 Ready to Execute |

---

## Contributing

This project is part of the [Organized AI](https://github.com/organized-ai) ecosystem. The plugin architecture follows the Organized Codebase template pattern.

### Adding Tracking References

New platform integration patterns go in `tracking-references/` following the existing format: problem statement, architecture diagram, implementation steps, and verification checklist.

### Extending Plugins

Each plugin in `plugin-marketplace/` follows the Claude Code plugin spec: `plugin.json` for metadata, `skills/` for knowledge, `agents/` for autonomy, `commands/` for execution, and `hooks/` for safety gates.

---

## Related Projects

- [gtm-ai-plugin](https://github.com/organized-ai/gtm-ai-plugin) — The original GTM plugin that OpenClaw extends
- [blade-linkedin-plugin](https://github.com/organized-ai/blade-linkedin-plugin) — LinkedIn-specific tracking deployment
- [sheepdog-movie](https://github.com/organized-ai) — Reference client implementation

---

*Built by [Organized AI](https://github.com/organized-ai) — Tracking infrastructure, automated.*
