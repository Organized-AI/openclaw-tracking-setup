# OpenClaw Plugin Suite — Claude Code Prompts

> **Repo**: https://github.com/Organized-AI/openclaw-tracking-setup
> **Local Path**: `/Users/supabowl/Library/Mobile Documents/com~apple~CloudDocs/BHT Promo iCloud/Organized AI/Windsurf/openclaw-tracking-setup`
> **Generated**: 2026-02-19

---

## Execution Order

| Phase | Plugin | Priority | Dependency |
|-------|--------|----------|------------|
| Phase 0 | All three scaffolds | First | None |
| Phase 1 | openclaw-gtm | Highest | Phase 0 |
| Phase 2 | openclaw-google-ads | Medium | Phase 0 |
| Phase 3 | openclaw-meta | Medium | Phase 0 + Phase 1 |
| Phase 4 | OpenClaw wrappers | After 1-3 | Phases 1-3 |
| Phase 5 | Integration testing | After 4 | All phases |
| Phase 6 | Bowser browser layer | After 0 | Phase 0 (enhances all) |

**Run Phase 0 first, then Phase 1. Phases 2 and 3 can run in parallel after Phase 0. Phase 6 (Bowser) can run any time after Phase 0 — it provides browser-based discovery, GTM Preview validation, and QA testing that enhances all other phases.**

---

## Phase 0: Scaffold All Three Plugins

### Claude Code Prompt (copy-paste)

```
claude --dangerously-skip-permissions

Clone and enter the OpenClaw repo:
cd "/Users/supabowl/Library/Mobile Documents/com~apple~CloudDocs/BHT Promo iCloud/Organized AI/Windsurf"
git clone https://github.com/Organized-AI/openclaw-tracking-setup.git || cd openclaw-tracking-setup && git pull
cd openclaw-tracking-setup

Create three Claude Code plugin scaffolds in the plugin-marketplace/ directory. Use the existing gtm-ai-plugin pattern as the structural template.

## Plugin 1: openclaw-google-ads

Create plugin-marketplace/openclaw-google-ads/ with this structure:

.claude-plugin/plugin.json:
{
  "name": "openclaw-google-ads",
  "description": "Autonomous Google Ads conversion tracking builder. Audits existing conversion actions via GAQL, generates deployment configurations, and validates tracking implementation.",
  "version": "1.0.0",
  "author": "BHT Labs"
}

mcp-servers.json:
{
  "mcpServers": {
    "google-ads-mcp": {
      "command": "npx",
      "args": ["-y", "@anthropic/google-ads-mcp"],
      "env": {
        "GOOGLE_ADS_DEVELOPER_TOKEN": "${GOOGLE_ADS_DEVELOPER_TOKEN}",
        "GOOGLE_ADS_LOGIN_CUSTOMER_ID": "${GOOGLE_ADS_LOGIN_CUSTOMER_ID}"
      }
    }
  }
}

Create these empty/placeholder files:
- skills/google-ads-builder/SKILL.md (placeholder: "# Google Ads Builder Skill")
- skills/google-ads-builder/references/conversion-types.md
- skills/google-ads-builder/references/gaql-patterns.md
- skills/google-ads-builder/references/naming-conventions.md
- agents/google-ads-agent.md
- commands/gads-audit.md
- commands/gads-deploy.md
- commands/gads-status.md
- hooks/hooks.json (empty array: [])
- hooks/pre-deploy-validation.md
- hooks/post-deploy-verification.md
- templates/conversion-action.template.json
- templates/remarketing-audience.template.json
- planning/IMPLEMENTATION-MASTER-PLAN.md
- openclaw/TOOLS.md
- openclaw/HEARTBEAT-ENTRIES.md
- openclaw/SCOPE-PHASE.md
- PLUGIN.md (placeholder with plugin name and description)
- README.md (placeholder)

Create install.sh that:
1. Checks for required env vars (GOOGLE_ADS_DEVELOPER_TOKEN, GOOGLE_ADS_LOGIN_CUSTOMER_ID)
2. Verifies Google Ads MCP connectivity by listing accounts
3. Copies plugin files to .claude/ directory
4. Makes it executable (chmod +x)

## Plugin 2: openclaw-meta

Create plugin-marketplace/openclaw-meta/ with this structure:

.claude-plugin/plugin.json:
{
  "name": "openclaw-meta",
  "description": "Autonomous Meta Pixel and Conversions API tracking builder. Deploys dual-tracking (client Pixel + server CAPI) via GTM and sGTM with event deduplication.",
  "version": "1.0.0",
  "author": "BHT Labs"
}

mcp-servers.json:
{
  "mcpServers": {
    "google-tag-manager-mcp-server": {
      "type": "url",
      "url": "https://gtm-mcp.stape.ai/mcp"
    },
    "stape-mcp-server": {
      "type": "sse",
      "url": "https://mcp.stape.ai/sse",
      "headers": {
        "x-api-key": "${STAPE_API_KEY}"
      }
    }
  }
}

Create these empty/placeholder files:
- skills/meta-tracking-builder/SKILL.md
- skills/meta-tracking-builder/references/standard-events.md
- skills/meta-tracking-builder/references/capi-parameters.md
- skills/meta-tracking-builder/references/deduplication-guide.md
- skills/meta-tracking-builder/references/naming-conventions.md
- agents/meta-tracking-agent.md
- commands/meta-audit.md
- commands/meta-deploy.md
- commands/meta-test-events.md
- commands/meta-status.md
- hooks/hooks.json
- hooks/pre-deploy-validation.md
- hooks/post-deploy-verification.md
- hooks/event-dedup-check.md
- templates/pixel-tag.template.json
- templates/capi-client.template.json
- templates/event-mapping.template.json
- planning/IMPLEMENTATION-MASTER-PLAN.md
- openclaw/TOOLS.md
- openclaw/HEARTBEAT-ENTRIES.md
- openclaw/SCOPE-PHASE.md
- PLUGIN.md
- README.md

Create install.sh that:
1. Checks for STAPE_API_KEY
2. Verifies GTM MCP and Stape MCP connectivity
3. Notes Pipeboard Meta MCP as optional enhancement
4. Copies plugin files

## Plugin 3: openclaw-gtm

Create plugin-marketplace/openclaw-gtm/ with this structure:

.claude-plugin/plugin.json:
{
  "name": "openclaw-gtm",
  "description": "Enhanced GTM orchestrator. Builds complete tracking configurations across web and server-side containers using Stape GTM MCP. Multi-platform tag deployment with pre-publish auditing.",
  "version": "1.0.0",
  "author": "BHT Labs"
}

mcp-servers.json (same GTM + Stape config as openclaw-meta)

Create these empty/placeholder files:
- skills/gtm-enhanced-builder/SKILL.md
- skills/gtm-enhanced-builder/references/tag-types.md
- skills/gtm-enhanced-builder/references/trigger-patterns.md
- skills/gtm-enhanced-builder/references/variable-types.md
- skills/gtm-enhanced-builder/references/sgtm-correlation.md
- skills/gtm-enhanced-builder/references/naming-conventions.md
- agents/gtm-orchestrator-agent.md
- commands/gtm-build.md
- commands/gtm-audit.md
- commands/gtm-publish.md
- commands/gtm-rollback.md
- commands/gtm-status.md
- hooks/hooks.json
- hooks/pre-publish-audit.md
- hooks/post-phase.md
- hooks/pre-phase.md
- hooks/ascii-diagram-generator.md
- templates/ga4-config.template.json
- templates/phase-state.template.json
- templates/config.template.json
- planning/IMPLEMENTATION-MASTER-PLAN.md
- openclaw/TOOLS.md
- openclaw/HEARTBEAT-ENTRIES.md
- openclaw/SCOPE-PHASE.md
- PLUGIN.md
- README.md

Create install.sh that:
1. Checks for STAPE_API_KEY
2. Verifies both GTM MCP and Stape MCP
3. Lists available GTM accounts/containers
4. Copies plugin files

## Verification

After creating all three plugins:
1. Verify each has a valid plugin.json
2. Verify each has an install.sh
3. Count total files created per plugin
4. Run: find plugin-marketplace/openclaw-* -type f | wc -l
5. Git add, commit, and push all new files
```

### Environment Variables for Claude Code Web

```
STAPE_API_KEY=<your-stape-key>
GOOGLE_ADS_DEVELOPER_TOKEN=<your-dev-token>
GOOGLE_ADS_LOGIN_CUSTOMER_ID=<your-login-cid>
```

---

## Phase 1: openclaw-gtm — Enhanced GTM Builder

### Claude Code Prompt (copy-paste)

```
claude --dangerously-skip-permissions

cd "/Users/supabowl/Library/Mobile Documents/com~apple~CloudDocs/BHT Promo iCloud/Organized AI/Windsurf/openclaw-tracking-setup"

Read these tracking reference files first for context:
- tracking-references/capig-setup-reference.md
- tracking-references/sgtm-client-patterns.md
- tracking-references/cross-platform-event-mapping.md
- tracking-references/dual-tracking-linkedin-reference.md

Then build out the openclaw-gtm plugin in plugin-marketplace/openclaw-gtm/. This is the FOUNDATION plugin — both Meta and Google Ads plugins depend on it for tag deployment.

## 1. SKILL.md — GTM Enhanced Builder

Write skills/gtm-enhanced-builder/SKILL.md as a comprehensive skill document. It must cover:

### Core Capabilities
- Container discovery: Use gtm_container (action: list) to find containers by account
- Workspace management: Use gtm_workspace to create/manage workspaces for isolated changes
- Full CRUD for: tags, triggers, variables, built-in variables, folders, templates, transformations, clients
- Version management: Create versions, publish, rollback
- Pre-publish auditing: Mandatory validation before any publish operation

### MCP Tool Reference
Document every GTM MCP tool with usage patterns:

**Container Operations:**
- gtm_account (list, get)
- gtm_container (list, get, create, update, snippet)
- gtm_workspace (list, get, create, createVersion, getStatus, sync, quickPreview)

**Entity CRUD:**
- gtm_tag (create, get, list, update, remove, revert)
- gtm_trigger (create, get, list, update, remove, revert)
- gtm_variable (create, get, list, update, remove, revert)
- gtm_built_in_variable (create, list, remove, revert)
- gtm_folder (create, get, list, update, remove, entities, moveEntitiesToFolder)
- gtm_template (create, get, list, update, remove, revert)
- gtm_client (create, get, list, update, remove, revert)
- gtm_transformation (create, get, list, update, remove, revert)

**Publishing:**
- gtm_version (get, live, publish, remove, setLatest, undelete, update)
- gtm_version_header (list, latest)

**Stape sGTM:**
- stape_container_crud (create, get, get_all, update, delete)
- stape_container_domains (list, get, create, validate)
- stape_container_power_ups (cookie_keeper, anonymizer, geo_headers, etc.)

### Phased Execution Model
Define the standard execution phases:
1. **Discovery** — List accounts, containers, workspaces. Read current state.
2. **Planning** — Define what tags/triggers/variables to create. Generate plan document.
3. **Variables** — Enable built-in variables, create custom variables (constants, data layer, custom JS)
4. **Triggers** — Create all triggers (page view, click, form submit, scroll, video, custom event)
5. **Tags** — Create all tags (GA4 config, GA4 events, conversion linker, etc.)
6. **Organization** — Create folders, move entities into folders for organization
7. **Validation** — Audit the workspace: check naming, duplicates, correlations, missing triggers
8. **Publishing** — Create version with description, publish to live

### Naming Conventions (from tracking-references/cross-platform-event-mapping.md)
Enforce these patterns:
- Tags: `{Platform} - {Type} - {Description}` (e.g., "GA4 - Event - free_trial_click")
- Triggers: `{Type} - {Description}` (e.g., "Click - Trial CTA")
- Variables: `{Type Prefix} - {Description}` (e.g., "DL - Button Test ID", "Const - GA4 ID")
- Folders: `{Platform}` or `{Function}` (e.g., "GA4", "Meta", "Utilities")

### sGTM Patterns (from tracking-references/sgtm-client-patterns.md)
Document the three-client pattern:
- GA4 Client (/g/collect) — production traffic
- Webhook Client (/webhook) — CRM offline events from GoHighLevel
- Data Client (/data) — testing/debugging

### Error Handling
- Always check workspace status before modifications
- Handle "already exists" errors gracefully (skip or update)
- Validate fingerprints for update operations
- Retry failed operations up to 3 times

## 2. Reference Documents

Write these reference files with full content:

**references/tag-types.md** — Catalog of GTM tag types with creation parameters:
- GA4 Configuration (gaawc)
- GA4 Event (gaawe)
- Conversion Linker (gclidw)
- Google Ads Conversion Tracking (awct)
- Google Ads Remarketing (sp)
- Custom HTML (html)
- Custom Image (img)
- Meta Pixel (via custom template)
- LinkedIn Insight Tag (via custom template)

**references/trigger-patterns.md** — Common trigger configurations:
- Page View (pageview, domReady, windowLoaded)
- Click (All Elements, Just Links) with CSS selector conditions
- Form Submission with form ID/class filters
- Scroll Depth (vertical percentages)
- YouTube Video (start, progress, complete)
- Custom Event (dataLayer push matching)
- Timer triggers
- Element Visibility

**references/variable-types.md** — Variable types and when to use:
- Built-in (Page URL, Click Text, Form ID, etc.)
- Data Layer Variable (dataLayer key path)
- Constant (measurement IDs, pixel IDs)
- Custom JavaScript (computed values)
- Lookup Table (value mapping)
- RegEx Table (pattern matching)
- Auto-Event Variable (element attribute)
- DOM Element

**references/sgtm-correlation.md** — How web GTM tags map to sGTM (use tracking-references/sgtm-client-patterns.md and dual-tracking-linkedin-reference.md as source):
- GA4 web tag -> GA4 sGTM client -> GA4 sGTM tag
- Meta Pixel web tag -> Meta CAPI sGTM client -> CAPI sGTM tag
- Event ID correlation for deduplication
- Data enrichment in sGTM (user data, server-side params)
- Three-client architecture diagram

**references/naming-conventions.md** — Complete naming standard with examples (use tracking-references/cross-platform-event-mapping.md as source)

## 3. Agent Definition

Write agents/gtm-orchestrator-agent.md as a comprehensive autonomous agent definition:
- Identity: GTM Orchestrator — autonomous builder using MCP tools
- Session protocol: Read agent def -> Identify target -> Assess state -> Execute plan -> Validate
- Tools available: All GTM MCP + Stape MCP tools
- Safety rules: Never publish without audit, always use dedicated workspace, create version before publishing
- Execution pattern for any deployment: Create workspace -> Built-in vars -> Custom vars -> Triggers -> Tags -> Folders -> Audit -> Version -> Publish

## 4. Commands

Write command definitions for each:
- commands/gtm-build.md — Takes tracking plan and deploys via phased execution
- commands/gtm-audit.md — Audits container for naming issues, orphans, duplicates, sGTM correlations
- commands/gtm-publish.md — Pre-publish audit -> Create version -> Publish -> Verify
- commands/gtm-rollback.md — List versions -> Restore specified version -> Verify
- commands/gtm-status.md — Current live version, pending changes, counts, last publish

## 5. Hooks

Write hooks/hooks.json with three hooks:
- pre-publish-audit: Mandatory validation before publish (naming, orphans, duplicates, missing triggers, conversion linker check, sGTM correlations)
- pre-phase: Verify workspace is clean, required vars exist, no conflicts
- post-phase: Count entities created, verify accessibility, log completion

Write each hook file (hooks/pre-publish-audit.md, hooks/pre-phase.md, hooks/post-phase.md) with detailed validation logic.

## 6. Templates

Write JSON template files:
- templates/ga4-config.template.json — GA4 Configuration tag with measurement ID, send page view, server container URL
- templates/config.template.json — Project configuration (account ID, container ID, measurement IDs, pixel IDs)
- templates/phase-state.template.json — Phase execution state tracking (current phase, completed phases, entity counts)

## Verification

After building:
1. Verify SKILL.md is comprehensive (should be 5000+ words)
2. Verify all 5 reference documents exist with substantive content
3. Verify agent definition includes safety rules
4. Verify all 5 commands have actionable instructions
5. Verify hooks.json is valid JSON
6. Verify all template JSON files are valid
7. Run: wc -l plugin-marketplace/openclaw-gtm/skills/gtm-enhanced-builder/SKILL.md
8. Git add, commit, and push all changes
```

### Environment Variables for Claude Code Web

```
STAPE_API_KEY=<your-stape-key>
```

---

## Phase 2: openclaw-google-ads

### Claude Code Prompt (copy-paste)

```
claude --dangerously-skip-permissions

cd "/Users/supabowl/Library/Mobile Documents/com~apple~CloudDocs/BHT Promo iCloud/Organized AI/Windsurf/openclaw-tracking-setup"

Read PROMPTS/PHASE-2-GOOGLE-ADS.md and execute its full instructions to build out plugin-marketplace/openclaw-google-ads/.

Also read these tracking references for context:
- tracking-references/cross-platform-event-mapping.md

Build the complete plugin content: SKILL.md (with GAQL query patterns, conversion action types, audiences), all reference docs, agent definition, commands (gads-audit, gads-deploy, gads-status), hooks, and templates.

After building, git add, commit, and push all changes.
```

### Environment Variables for Claude Code Web

```
GOOGLE_ADS_DEVELOPER_TOKEN=<your-dev-token>
GOOGLE_ADS_LOGIN_CUSTOMER_ID=<your-login-cid>
```

---

## Phase 3: openclaw-meta

### Claude Code Prompt (copy-paste)

```
claude --dangerously-skip-permissions

cd "/Users/supabowl/Library/Mobile Documents/com~apple~CloudDocs/BHT Promo iCloud/Organized AI/Windsurf/openclaw-tracking-setup"

Read PROMPTS/PHASE-3-META.md and execute its full instructions to build out plugin-marketplace/openclaw-meta/.

Also read these tracking references for context:
- tracking-references/capig-setup-reference.md
- tracking-references/sgtm-client-patterns.md
- tracking-references/cross-platform-event-mapping.md
- tracking-references/dual-tracking-linkedin-reference.md

Build the complete plugin content: SKILL.md (with dual-tracking architecture, CAPIG setup, standard events, deduplication), all reference docs, agent definition, commands (meta-audit, meta-deploy, meta-test-events, meta-status), hooks (including event-dedup-check), and templates.

After building, git add, commit, and push all changes.
```

### Environment Variables for Claude Code Web

```
STAPE_API_KEY=<your-stape-key>
META_PIXEL_ID=<your-pixel-id>
META_ACCESS_TOKEN=<your-meta-token>
```

---

## Phase 4: OpenClaw Workspace Wrappers

### Claude Code Prompt (copy-paste)

```
claude --dangerously-skip-permissions

cd "/Users/supabowl/Library/Mobile Documents/com~apple~CloudDocs/BHT Promo iCloud/Organized AI/Windsurf/openclaw-tracking-setup"

Read PROMPTS/PHASE-4-OPENCLAW-WRAPPERS.md and execute its full instructions.

For each of the three plugins (openclaw-gtm, openclaw-google-ads, openclaw-meta), write the OpenClaw workspace wrappers:
- openclaw/TOOLS.md — MCP tools with risk levels (LOW/MEDIUM/HIGH)
- openclaw/HEARTBEAT-ENTRIES.md — Scheduled audit tasks (weekly/monthly in SANDBOX mode)
- openclaw/SCOPE-PHASE.md — Phased deployment checklists

After building, git add, commit, and push all changes.
```

### Environment Variables for Claude Code Web

```
STAPE_API_KEY=<your-stape-key>
GOOGLE_ADS_DEVELOPER_TOKEN=<your-dev-token>
GOOGLE_ADS_LOGIN_CUSTOMER_ID=<your-login-cid>
```

---

## Phase 5: Integration Testing

### Claude Code Prompt (copy-paste)

```
claude --dangerously-skip-permissions

cd "/Users/supabowl/Library/Mobile Documents/com~apple~CloudDocs/BHT Promo iCloud/Organized AI/Windsurf/openclaw-tracking-setup"

Read PROMPTS/PHASE-5-INTEGRATION.md and execute its full instructions.

Test the three OpenClaw plugins together by running a simulated deployment against GTM-KV4V3H8W (Wonder Project) as the test target.

1. Plugin Connectivity Test — Verify MCP tool access for each plugin
2. Dry-Run Deployment Test — READ-ONLY audit flow (GTM audit, Google Ads audit, Meta audit)
3. Cross-Plugin Workflow Test — Test handoff between plugins
4. Generate integration-test-report.md
5. Write comprehensive PLUGIN.md and README.md for each of the three plugins

After testing, git add, commit, and push all changes.
```

### Environment Variables for Claude Code Web

```
STAPE_API_KEY=<your-stape-key>
GOOGLE_ADS_DEVELOPER_TOKEN=<your-dev-token>
GOOGLE_ADS_LOGIN_CUSTOMER_ID=<your-login-cid>
META_PIXEL_ID=<your-pixel-id>
META_ACCESS_TOKEN=<your-meta-token>
```

---

## Phase 6: Bowser Browser Layer — Discovery, GTM Preview & QA

> **Source**: [disler/bowser](https://github.com/disler/bowser) — Agentic browser automation for Claude Code
> **Plan**: `PLANNING/BOWSER-OPENCLAW-INTEGRATION-PLAN.md`

### Claude Code Prompt (copy-paste)

```
claude --dangerously-skip-permissions

cd "/Users/supabowl/Library/Mobile Documents/com~apple~CloudDocs/BHT Promo iCloud/Organized AI/Windsurf/openclaw-tracking-setup"

Read PLANNING/BOWSER-OPENCLAW-INTEGRATION-PLAN.md first — it contains the full architecture, skill definitions, agent patterns, and YAML story format.

Also read:
- OPENCLAW-CLAUDE-CODE-PROMPTS.md (existing phase structure)
- .claude/ directory (existing skill/agent/command structure from Organized Codebase)

You are building the browser automation layer for OpenClaw. This adds three capabilities:
1. **Page Discovery** — Scrape websites to identify GTM tracking opportunities (Tags, Triggers, Variables)
2. **GTM Preview Validation** — Test tag firing in real Chrome with GTM Preview mode
3. **Conversion QA** — YAML story-based test scenarios that validate tracking implementations

## What to Build

### 1. Skills (.claude/skills/)

**openclaw-discovery/SKILL.md**
- Playwright-Bowser based page scraping skill
- Visits URLs, captures accessibility tree snapshots via `playwright-cli snapshot`
- Classifies elements: forms → Form Submission triggers, buttons → Click triggers, videos → YouTube triggers, scroll containers → Scroll Depth triggers, tel:/mailto: links → Link Click triggers, data-* attributes → Custom Event triggers
- Inspects dataLayer via `playwright-cli run-code "JSON.stringify(window.dataLayer || [])"`
- Checks existing tracking: fbq, gtag, google_tag_manager objects
- Captures network baseline via `playwright-cli network`
- Outputs structured YAML discovery report (see plan for format)
- Key commands: open, snapshot, screenshot, run-code, network

**openclaw-preview/SKILL.md**
- Chrome MCP based GTM Preview validation skill
- Pre-flight: check mcp__claude_in_chrome__tabs_context_mcp exists, resize to 1440x900
- Read dataLayer via javascript_tool: `JSON.stringify(window.dataLayer.filter(e => typeof e === 'object'), null, 2)`
- Capture network requests via read_network_requests with urlPattern filters
- Filter for: google-analytics.com, googleads.g.doubleclick.net, facebook.com/tr, ads.linkedin.com, analytics.tiktok.com, tr.snapchat.com
- Check console via read_console_messages with pattern "GTM|gtm|dataLayer|error|Error"
- Screenshot GTM Preview panel state
- Generate validation report: expected vs actual tag firing

**openclaw-qa/SKILL.md**
- YAML story execution skill for tracking validation
- Reads story files from stories/ directory
- Executes steps sequentially: navigate → fill → click → wait
- After each action step, validates:
  - dataLayer contains expected events with correct parameters
  - Network requests to tracking endpoints were fired
  - Console has no errors
- Reports PASS/FAIL per step with screenshots as evidence
- Uses either Playwright or Chrome MCP depending on story config

### 2. Agents (.claude/agents/)

**discovery-agent.md**
- Autonomous agent that crawls N pages of a website
- Uses openclaw-discovery skill
- Produces comprehensive tracking opportunity YAML report
- Maps each opportunity to specific GTM tag/trigger/variable configs ready for openclaw-gtm
- Model: opus for thorough analysis

**preview-agent.md**
- Connects to Chrome browser with GTM Preview active
- Uses openclaw-preview skill
- Navigates through specified user journeys
- Captures and validates all tag firings against expected configuration
- Reports mismatches with screenshot evidence

**qa-agent.md**
- Based on Bowser's bowser-qa-agent.md pattern
- Uses openclaw-qa skill
- Executes YAML stories from stories/ directory
- Sequential step execution with screenshots
- PASS/FAIL per step with evidence (dataLayer state, network requests, console output)
- Structured report table format

### 3. Commands (.claude/commands/)

**discover.md**: "Discover tracking opportunities on $ARGUMENTS" — Takes a URL, runs discovery agent, outputs YAML report
**validate.md**: "Validate GTM Preview for $ARGUMENTS" — Takes a URL, opens Chrome MCP, validates tag firing
**qa-run.md**: "Run QA stories for $ARGUMENTS" — Takes a story file or directory, executes all stories
**full-audit.md**: "Run full discovery + validation + QA pipeline" — Chains all three: discover → validate → qa-run

### 4. Story Templates (stories/templates/)

Create YAML templates for common tracking scenarios:

**lead-form.yaml** — Form submission fires: GA4 generate_lead, Meta Lead, Google Ads conversion
**ecommerce-purchase.yaml** — Add to cart → checkout → purchase fires: GA4 purchase, Meta Purchase, Google Ads conversion with value
**phone-click.yaml** — tel: link click fires: GA4 phone_click, Google Ads call conversion
**video-engagement.yaml** — YouTube video start/progress/complete fires: GA4 video events
**scroll-depth.yaml** — 25/50/75/100% scroll fires: GA4 scroll events

Each story must follow the YAML format defined in the integration plan (steps with action, selector, validate blocks).

### 5. Endpoint Registry (endpoints/tracking-endpoints.yaml)

Define all known tracking endpoints with pattern and key_params:
- ga4, google_ads, meta_pixel, meta_capi, linkedin, tiktok, snapchat, sgtm

### 6. Directory Structure

Create these directories with .gitkeep:
- stories/clients/
- reports/

## Key Patterns from Bowser

Follow Bowser's four-layer architecture:
- **Skills** are capabilities (single concern, reusable)
- **Agents** scale skills (autonomous, structured output)
- **Commands** orchestrate agents (user-facing entry points)
- **Stories** define test scenarios declaratively (YAML)

Always screenshot on failure. Structured PASS/FAIL reporting for all QA.

## Dependencies

- playwright-cli (for headless discovery — install via npm if not present)
- Chrome MCP tools (for GTM Preview — requires claude --chrome flag)
- GTM MCP tools from Stape (for creating tags/triggers/variables from discovery results)

## Verification

After building:
1. Verify all 3 skill SKILL.md files exist with substantive content
2. Verify all 3 agent .md files follow Bowser patterns
3. Verify all 4 command .md files are actionable
4. Verify all 5 YAML story templates parse correctly
5. Verify tracking-endpoints.yaml is valid YAML
6. Verify directory structure matches the integration plan
7. Run: find .claude/skills/openclaw-* -type f | wc -l
8. Run: find stories/ -name "*.yaml" | wc -l
9. Git add, commit, and push all changes
```

### Environment Variables for Claude Code Web

```
STAPE_API_KEY=<your-stape-key>
PLAYWRIGHT_MCP_VIEWPORT_SIZE=1440x900
```
