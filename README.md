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

## CLI Tools

OpenClaw includes a full CLI suite built on the [mcporter](https://github.com/steipete/mcporter) pattern — pure bash scripts that wrap MCP server calls into composable commands.

### Installation

```bash
# Install mcporter (required dependency)
npm install -g @nicepkg/mcporter

# Clone the repo and make CLI tools executable
git clone https://github.com/Organized-AI/openclaw-tracking-setup.git
cd openclaw-tracking-setup
chmod +x CLI-TOOLS/openclaw CLI-TOOLS/openclaw-*

# Add to PATH (optional)
export PATH="$PATH:$(pwd)/CLI-TOOLS"
```

### CLI Architecture

```
CLI-TOOLS/
├── openclaw              # Main entry point — routes to sub-tools
├── openclaw-gtm          # GTM container operations
├── openclaw-gads         # Google Ads GAQL queries & conversion audit
├── openclaw-meta         # Meta Pixel + CAPI audit & event mapping
├── openclaw-stape        # Stape sGTM container management
├── openclaw-discover     # Site crawl & tracking opportunity discovery
├── openclaw-preview      # GTM Preview mode validation
├── openclaw-qa           # YAML test story runner
├── lib/
│   ├── common.sh         # Shared utilities, colors, logging, mcporter wrapper
│   └── gtm-helpers.sh    # GTM MCP helper functions
├── config/
│   └── mcporter.json     # MCP server definitions
├── google-ads/           # Google Ads deployment & credential scripts
│   ├── *.sh              # 9 deployment/verification scripts
│   ├── oauth-server.py   # Python OAuth callback server
│   ├── config/
│   │   └── exec-approvals.json  # Tool authorization (24 read + 11 write)
│   └── README.md         # Google Ads CLI documentation
└── stories/              # QA test story files (YAML)
```

### Environment Variables

```bash
# GTM (required for gtm, meta, preview commands)
export GTM_ACCOUNT_ID="your-account-id"
export GTM_CONTAINER_ID="your-container-id"
export GTM_WORKSPACE_ID="your-workspace-id"

# Stape (required for stape commands)
export STAPE_CONTAINER_ID="your-stape-container-id"

# Google Ads (required for gads commands)
export GOOGLE_ADS_CUSTOMER_ID="your-customer-id"
export GOOGLE_ADS_LOGIN_CUSTOMER_ID="your-login-cid"
```

### Usage

```bash
# Check environment and MCP server connectivity
openclaw env

# ─── GTM Operations ───
openclaw gtm audit              # Full container audit (tags + triggers + vars + clients)
openclaw gtm list-tags           # List all tags
openclaw gtm list-triggers       # List all triggers
openclaw gtm list-vars           # List all variables
openclaw gtm list-clients        # List sGTM clients
openclaw gtm status              # Workspace change status
openclaw gtm publish             # Create version and publish (with confirmation)

# ─── Google Ads ───
openclaw gads accounts           # List accessible accounts
openclaw gads conversions        # Audit all conversion actions
openclaw gads campaigns          # Campaign performance metrics
openclaw gads query 'SELECT campaign.name FROM campaign'  # Custom GAQL

# ─── Meta ───
openclaw meta audit              # Audit Meta/Facebook tags in GTM
openclaw meta pixel-tags         # List Pixel tag configurations
openclaw meta event-map          # GA4 ↔ Meta event mapping table

# ─── Stape sGTM ───
openclaw stape containers        # List all Stape containers
openclaw stape get --id ABC123   # Get container details
openclaw stape domains --id X    # List container domains
openclaw stape power-ups --id X  # Check power-up status

# ─── Site Discovery ───
openclaw discover https://example.com              # Crawl and identify tracking opportunities
openclaw discover https://example.com --depth 3    # Deeper crawl
openclaw discover https://example.com --format json # JSON output

# ─── GTM Preview Validation ───
openclaw preview https://example.com                    # Basic validation
openclaw preview https://example.com --full             # Full validation suite
openclaw preview https://example.com --check-consent    # Consent mode check

# ─── QA Test Stories ───
openclaw qa init my-test                  # Create test story template
openclaw qa run stories/my-test.yaml      # Run test story
openclaw qa validate stories/my-test.yaml # Validate YAML syntax
openclaw qa list                          # List available stories
```

### How the CLI Works

Each CLI tool wraps MCP server calls via mcporter. For example, `openclaw gtm list-tags` translates to:

```bash
mcporter call gtm-mcp-server.gtm_tag \
  action:list \
  accountId:$GTM_ACCOUNT_ID \
  containerId:$GTM_CONTAINER_ID \
  workspaceId:$GTM_WORKSPACE_ID
```

The `mcp()` wrapper function in `lib/common.sh` handles mcporter detection, fallback to npx, and JSON output formatting. GTM-specific operations live in `lib/gtm-helpers.sh` as reusable bash functions shared across `openclaw-gtm` and `openclaw-meta`.

---

## Google Ads CLI Tools

The `CLI-TOOLS/google-ads/` directory contains deployment, credential management, and verification scripts for the full 35-tool Google Ads CLI inventory (24 read + 11 write across 9 categories).

### Tool Inventory (35 Tools)

| Category | Read Tools | Write Tools | Total |
|----------|-----------|-------------|-------|
| Campaigns | `list-campaigns`, `get-campaign`, `campaign-performance` | `create-campaign`, `update-campaign`, `pause-campaign` | 6 |
| Ad Groups | `list-ad-groups`, `get-ad-group`, `ad-group-performance` | `create-ad-group`, `update-ad-group` | 5 |
| Ads | `list-ads`, `get-ad`, `ad-performance` | — | 3 |
| Keywords | `list-keywords`, `keyword-performance`, `search-terms` | `add-keywords`, `update-keyword-bids` | 5 |
| Performance | `account-performance`, `daily-performance`, `device-performance`, `geo-performance` | — | 4 |
| Accounts | `list-accounts`, `account-info` | — | 2 |
| Analytics | `auction-insights`, `quality-score`, `change-history` | — | 3 |
| Conversions | `list-conversions`, `conversion-performance` | `create-conversion-action`, `update-conversion` | 4 |
| Shopping | `list-products`, `shopping-performance` | `update-product-group` | 3 |

### Deployment Scripts

| Script | Purpose |
|--------|---------|
| `deploy-google-ads-credentials.sh` | Deploy API credentials (JSON + YAML) to Mac Mini via Tailscale SSH |
| `deploy-google-ads-tools-md.sh` | Deploy TOOLS.md to Mac Mini for agent write authorization |
| `diagnose-google-ads.sh` | Diagnostic check across 4 credential locations |
| `fix-google-ads-credentials.sh` | Interactive credential setup wizard |
| `generate-google-ads-refresh-token.sh` | CLI OAuth flow (copy-paste auth code) |
| `generate-google-ads-token-web.sh` | Web OAuth flow (local HTTP server callback) |
| `monitor-google-ads-cli.sh` | Health monitor with Telegram/email/desktop alerts |
| `setup-google-ads-on-macmini.sh` | Full Mac Mini credential setup (run directly on target) |
| `verify-google-ads-deployment.sh` | 4-layer verification for all 35 tools |
| `verify-tool-deployment.sh` | Generic OpenClaw tool verifier (reusable) |
| `oauth-server.py` | Python OAuth callback server for web flow |

### 4-Layer Verification

The verification scripts follow a layered approach:

1. **Infrastructure** — Binary exists, PATH configured, credential files present
2. **Read Tools** — 14 read tool API tests with live responses
3. **Write Tools** — 11 write tool syntax checks (optional `--write` flag for live API)
4. **Agent Integration** — TOOLS.md references, gateway connectivity, exec-approvals config

### Exec-Approvals

The `config/exec-approvals.json` file controls which CLI subcommands an agent can execute (deny by default). It defines three rules: `allow-google-ads-read` (24 tools), `allow-google-ads-write` (11 tools), and `allow-google-ads-help`.

### Required Environment Variables

```bash
export GOOGLE_ADS_DEVELOPER_TOKEN="your-developer-token"
export GOOGLE_ADS_CLIENT_ID="your-oauth-client-id"
export GOOGLE_ADS_CLIENT_SECRET="your-oauth-client-secret"
export GOOGLE_ADS_REFRESH_TOKEN="your-refresh-token"
export GOOGLE_ADS_LOGIN_CUSTOMER_ID="your-mcc-customer-id"
```

---

## Repository Structure

```
openclaw-tracking-setup/
├── .claude/                          # Claude Code configuration
├── CLAUDE.md                         # Project instructions for Claude
├── OPENCLAW-MASTER-PLAN.md           # Architecture & MCP tool inventory
├── OPENCLAW-CLAUDE-CODE-PROMPTS.md   # All 7 phase prompts (copy-paste ready)
│
├── CLI-TOOLS/                        # Bash CLI suite (mcporter pattern)
│   ├── openclaw                      # Main dispatcher
│   ├── openclaw-gtm                  # GTM operations
│   ├── openclaw-gads                 # Google Ads queries
│   ├── openclaw-meta                 # Meta Pixel + CAPI
│   ├── openclaw-stape                # Stape sGTM management
│   ├── openclaw-discover             # Site discovery agent
│   ├── openclaw-preview              # GTM Preview validation
│   ├── openclaw-qa                   # QA test story runner
│   ├── lib/                          # Shared libraries
│   ├── config/                       # MCP server config
│   └── google-ads/                   # Google Ads deployment & credential scripts
│       ├── deploy-google-ads-credentials.sh
│       ├── deploy-google-ads-tools-md.sh
│       ├── diagnose-google-ads.sh
│       ├── fix-google-ads-credentials.sh
│       ├── generate-google-ads-refresh-token.sh
│       ├── generate-google-ads-token-web.sh
│       ├── monitor-google-ads-cli.sh
│       ├── setup-google-ads-on-macmini.sh
│       ├── verify-google-ads-deployment.sh
│       ├── verify-tool-deployment.sh
│       ├── oauth-server.py
│       ├── config/exec-approvals.json
│       └── README.md
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
- [mcporter](https://github.com/steipete/mcporter) installed (`npm install -g @nicepkg/mcporter`)
- MCP servers configured: GTM MCP (Stape), Google Ads MCP, Stape MCP
- Access to target GTM container and ad platform accounts

### Environment Variables

```bash
# Required for all plugins
export STAPE_API_KEY="your-stape-api-key"

# GTM identifiers
export GTM_ACCOUNT_ID="your-account-id"
export GTM_CONTAINER_ID="your-container-id"
export GTM_WORKSPACE_ID="your-workspace-id"

# Google Ads
export GOOGLE_ADS_DEVELOPER_TOKEN="your-dev-token"
export GOOGLE_ADS_LOGIN_CUSTOMER_ID="your-login-cid"
export GOOGLE_ADS_CUSTOMER_ID="your-customer-id"

# Meta (requires Pipeboard connection)
export META_ACCESS_TOKEN="your-meta-token"
export META_PIXEL_ID="your-pixel-id"

# Stape
export STAPE_CONTAINER_ID="your-stape-container-id"

# Bowser (Phase 6)
export PLAYWRIGHT_MCP_VIEWPORT_SIZE=1440x900
```

### Build the Plugins

```bash
# Clone the repo
git clone https://github.com/Organized-AI/openclaw-tracking-setup.git
cd openclaw-tracking-setup

# Make CLI tools executable
chmod +x CLI-TOOLS/openclaw CLI-TOOLS/openclaw-*

# Check your environment
./CLI-TOOLS/openclaw env

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
| **Google Ads CLI** | 35 tools across 9 categories (24 read + 11 write) | openclaw-google-ads, verification scripts |
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
| CLI Tools (8 sub-tools + libraries) | ✅ Complete |
| Google Ads CLI Tools (35 tools + 11 scripts) | ✅ Complete |
| Newsletter & LinkedIn Post | ✅ Complete |
| Plugin Build (Phases 0-6) | 🔲 Ready to Execute |

---

## Contributing

This project is part of the [Organized AI](https://github.com/organized-ai) ecosystem. The plugin architecture follows the Organized Codebase template pattern.

### Adding Tracking References

New platform integration patterns go in `tracking-references/` following the existing format: problem statement, architecture diagram, implementation steps, and verification checklist.

### Extending Plugins

Each plugin in `plugin-marketplace/` follows the Claude Code plugin spec: `plugin.json` for metadata, `skills/` for knowledge, `agents/` for autonomy, `commands/` for execution, and `hooks/` for safety gates.

### Extending CLI Tools

New CLI tools follow the same pattern: create a `CLI-TOOLS/openclaw-{name}` bash script, source `lib/common.sh` for utilities, and use the `mcp()` wrapper function for MCP server calls. Add the tool's routing entry to the main `openclaw` dispatcher.

### Adding Google Ads Tools

New Google Ads deployment scripts go in `CLI-TOOLS/google-ads/`. Update `config/exec-approvals.json` to register new tool subcommands. Follow the 4-layer verification pattern and run `verify-google-ads-deployment.sh` to validate.

---

## Related Projects

- [gtm-ai-plugin](https://github.com/organized-ai/gtm-ai-plugin) — The original GTM plugin that OpenClaw extends
- [blade-linkedin-plugin](https://github.com/organized-ai/blade-linkedin-plugin) — LinkedIn-specific tracking deployment
- [mcporter](https://github.com/steipete/mcporter) — MCP-to-CLI toolkit powering the OpenClaw CLI suite
- [sheepdog-movie](https://github.com/organized-ai) — Reference client implementation

---

*Built by [Organized AI](https://github.com/organized-ai) — Tracking infrastructure, automated.*
