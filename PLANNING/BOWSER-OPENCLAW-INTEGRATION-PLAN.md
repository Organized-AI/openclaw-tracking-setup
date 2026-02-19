# Bowser + OpenClaw Integration Plan

## Browser-Powered GTM Discovery, Validation & Conversion Testing

**Repo**: `Organized-AI/openclaw-tracking-setup`
**Source**: [disler/bowser](https://github.com/disler/bowser) — Agentic browser automation for Claude Code
**Purpose**: Scrape pages to identify GTM Tag/Trigger/Variable opportunities, test via GTM Preview, and validate conversion firing

---

## Why Bowser for OpenClaw

OpenClaw already has GTM MCP tools (Stape) for creating tags, triggers, and variables programmatically. What's missing is the **browser layer** — the ability to:

- Visit a client's website and **automatically identify** what should be tracked
- Open GTM Preview mode and **validate tags fire correctly** on real pages
- Run **automated QA stories** that simulate user journeys and verify conversion events
- Intercept **network requests** to confirm pixel/tag payloads reach their endpoints

Bowser provides exactly this through two complementary browser approaches and a composable four-layer architecture.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    OpenClaw + Bowser                     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────┐   ┌──────────────┐   ┌─────────────┐  │
│  │  Discovery   │   │  GTM Preview │   │  Conversion │  │
│  │  Agent       │   │  Validator   │   │  QA Agent   │  │
│  │             │   │              │   │             │  │
│  │ Playwright  │   │ Chrome MCP   │   │ Either Mode │  │
│  │ (headless)  │   │ (observable) │   │ + YAML      │  │
│  └──────┬──────┘   └──────┬───────┘   └──────┬──────┘  │
│         │                 │                   │         │
│         ▼                 ▼                   ▼         │
│  ┌─────────────────────────────────────────────────┐    │
│  │           Shared Analysis Layer                  │    │
│  │  • Page element classification                  │    │
│  │  • dataLayer inspection                         │    │
│  │  • Network request filtering                    │    │
│  │  • Tag/Trigger/Variable mapping                 │    │
│  └──────────────────────┬──────────────────────────┘    │
│                         │                               │
│                         ▼                               │
│  ┌─────────────────────────────────────────────────┐    │
│  │           GTM MCP Tools (Stape)                  │    │
│  │  • gtm_tag (create/update)                      │    │
│  │  • gtm_trigger (create/update)                  │    │
│  │  • gtm_variable (create/update)                 │    │
│  │  • gtm_workspace (publish)                      │    │
│  └─────────────────────────────────────────────────┘    │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Two Browser Modes & When to Use Each

| Capability | Playwright-Bowser (Headless) | Chrome-Bowser (Chrome MCP) |
|---|---|---|
| **Page scraping / discovery** | ✅ Primary — fast, parallel | Backup for JS-heavy SPAs |
| **GTM Preview testing** | ❌ No GTM extension | ✅ Primary — real browser profile |
| **Network request interception** | ✅ `playwright-cli network` | ✅ `read_network_requests` |
| **dataLayer reading** | ✅ `playwright-cli run-code` | ✅ `javascript_tool` |
| **Parallel execution** | ✅ Named sessions | ❌ Single instance |
| **Visual debugging** | Screenshots only | Observable in real-time |
| **Conversion QA stories** | ✅ Headless validation | ✅ Visual validation |

**Rule of thumb**: Playwright for discovery/scraping, Chrome MCP for GTM Preview validation.

---

## Phase 1: Discovery Agent — Page Scraping for GTM Opportunities

### What It Does
Crawls a client website and produces a structured report of every trackable element, mapped to recommended GTM Tags, Triggers, and Variables.

### Skill Definition: `openclaw-discovery`

```markdown
# OpenClaw Discovery Skill

## When to Use
When analyzing a new client website to identify tracking opportunities before
configuring GTM.

## Workflow

### Step 1: Crawl & Snapshot
Use Playwright-Bowser to visit each key page:

playwright-cli -s=discovery open <url> --persistent
playwright-cli snapshot
playwright-cli screenshot --filename=page-<slug>.png

### Step 2: Element Classification
From the accessibility tree snapshot, classify elements into tracking categories:

| Element Type | GTM Trigger Type | Example |
|---|---|---|
| `<form>` with submit button | Form Submission | Contact form, lead gen |
| `<button>`, `<a>` CTA | Click - All Elements | "Book Now", "Add to Cart" |
| `<video>`, `<iframe[youtube]>` | YouTube Video | Embedded video tracking |
| Scroll containers / long pages | Scroll Depth | 25/50/75/100% thresholds |
| `<a href="tel:">`, `<a href="mailto:">` | Click - Just Links | Phone/email click tracking |
| Page URL patterns | Page View | Virtual pageviews for SPAs |
| Custom `data-*` attributes | Custom Event | Developer-defined events |

### Step 3: dataLayer Inspection
Execute JavaScript to check existing tracking:

playwright-cli run-code "JSON.stringify(window.dataLayer || [])"
playwright-cli run-code "JSON.stringify(Object.keys(window.google_tag_manager || {}))"
playwright-cli run-code "typeof fbq !== 'undefined' ? 'Meta Pixel loaded' : 'No Meta Pixel'"
playwright-cli run-code "typeof gtag !== 'undefined' ? 'gtag loaded' : 'No gtag'"

### Step 4: Network Baseline
Capture what's already firing:

playwright-cli network

Filter for known tracking endpoints:
- google-analytics.com/g/collect — GA4
- googleads.g.doubleclick.net — Google Ads
- facebook.com/tr — Meta Pixel
- snap.com/ssc — Snapchat
- ads.linkedin.com — LinkedIn
- analytics.tiktok.com — TikTok

### Step 5: Generate Discovery Report
Output a structured tracking opportunity report with:
- Page URL
- Element found (selector + description)
- Recommended Tag type
- Recommended Trigger type + conditions
- Recommended Variables needed
- Priority (High/Medium/Low based on conversion proximity)
```

### Output Format: Discovery Report

```yaml
# discovery-report.yaml
site: "https://example.com"
pages_crawled: 12
existing_tracking:
  ga4: true
  meta_pixel: false
  google_ads: false
  gtm_container: "GTM-XXXXXXX"

opportunities:
  - page: "/contact"
    element: "form#contact-form"
    selector: "form#contact-form"
    action: "Form submission"
    priority: "High"
    recommended:
      tag:
        type: "GA4 Event"
        event_name: "generate_lead"
        parameters:
          form_name: "contact"
      trigger:
        type: "Form Submission"
        conditions:
          - "Page Path contains /contact"
      variables:
        - name: "Form ID"
          type: "DOM Element"
          selector: "form"
          attribute: "id"

  - page: "/"
    element: "button.cta-primary"
    selector: "button.cta-primary"
    action: "CTA click"
    priority: "High"
    recommended:
      tag:
        type: "GA4 Event"
        event_name: "cta_click"
        parameters:
          cta_text: "{{Click Text}}"
      trigger:
        type: "Click - All Elements"
        conditions:
          - "Click Classes contains cta-primary"
      variables:
        - name: "Click Text"
          type: "Auto-Event Variable"
          variable_type: "Element Text"
```

---

## Phase 2: GTM Preview Validator — Testing Tag Firing

### What It Does
Opens GTM Preview mode in the real Chrome browser (Chrome MCP), navigates through user journeys, and validates that tags fire with correct data.

### Skill Definition: `openclaw-preview`

```markdown
# OpenClaw GTM Preview Skill

## Prerequisites
- GTM Preview mode active (user opens GTM > Preview)
- Chrome MCP available (claude --chrome)

## Workflow

### Step 1: Connect to Browser
Pre-flight check for mcp__claude_in_chrome__tabs_context_mcp
Resize window to 1440x900

### Step 2: Navigate to Target Page
mcp__claude_in_chrome__navigate to client URL

### Step 3: Read dataLayer State
Use javascript_tool to execute:
JSON.stringify(window.dataLayer.filter(e => typeof e === 'object'), null, 2)

### Step 4: Perform Action (e.g., form submit, button click)
Use find tool to locate element, then computer tool to click

### Step 5: Capture Network Requests Post-Action
Use read_network_requests with urlPattern filters for tracking endpoints

### Step 6: Read Console for Errors
Use read_console_messages with pattern "GTM|gtm|dataLayer|error|Error"

### Step 7: Screenshot GTM Preview Panel
Use computer tool screenshot action

### Step 8: Generate Validation Report
Compare expected vs actual:
- Tag fired / Tag did not fire
- Correct event name / Wrong event name
- Parameters match / Missing parameters
- No console errors / Errors detected
```

---

## Phase 3: Conversion QA Agent — YAML Story-Based Testing

### What It Does
Runs structured test scenarios (YAML stories) that simulate user journeys and validate every tracking touchpoint fires correctly.

### Agent Definition: `openclaw-qa-agent`

Based on Bowser's `bowser-qa-agent.md` pattern but specialized for tracking validation.

```markdown
# OpenClaw QA Agent

You are a tracking QA specialist. You execute user story steps and validate
that GTM tags, conversion pixels, and dataLayer events fire correctly.

## Process
1. Read the YAML story file
2. For each step:
   a. Execute the browser action
   b. Check dataLayer for expected events
   c. Check network requests for expected pixel calls
   d. Screenshot the result
   e. Record PASS/FAIL with evidence
3. Generate structured QA report

## Validation Checks Per Step
- dataLayer event present with correct parameters
- Network request to tracking endpoint detected
- No JavaScript console errors
- Correct HTTP status codes on tracking requests
- Request payload contains expected parameters

## Report Format

| # | Step | Action | Expected Event | Network Hit | Status |
|---|------|--------|---------------|-------------|--------|
| 1 | Navigate to /contact | Page load | page_view | GA4 collect | PASS |
| 2 | Fill form | Input | - | - | PASS |
| 3 | Submit form | Click | generate_lead | GA4 + Meta | PASS |
```

### YAML Story Format for Tracking Validation

```yaml
# stories/lead-form-tracking.yaml
name: "Lead Form Conversion Tracking"
description: "Validates form submission fires GA4, Meta CAPI, and Google Ads conversion"
url: "https://client-site.com/contact"

steps:
  - action: navigate
    url: "https://client-site.com/contact"
    validate:
      dataLayer:
        - event: "page_view"
      network:
        - pattern: "google-analytics.com/g/collect"
          params:
            en: "page_view"

  - action: fill
    selector: "input[name='email']"
    value: "test@example.com"

  - action: fill
    selector: "input[name='name']"
    value: "Test User"

  - action: click
    selector: "button[type='submit']"
    wait: 3000
    validate:
      dataLayer:
        - event: "generate_lead"
          params:
            form_name: "contact"
      network:
        - pattern: "google-analytics.com/g/collect"
          params:
            en: "generate_lead"
        - pattern: "facebook.com/tr"
          params:
            ev: "Lead"
        - pattern: "googleads.g.doubleclick.net/pagead/conversion"
      console:
        no_errors: true

  - action: screenshot
    filename: "lead-form-post-submit.png"
```

---

## Phase 4: Network Request Analyzer

### Tracking Endpoint Registry

```yaml
# Known tracking endpoints for network filtering
endpoints:
  ga4:
    pattern: "google-analytics.com/g/collect"
    key_params: ["v", "tid", "en", "ep.*"]

  google_ads:
    pattern: "googleads.g.doubleclick.net/pagead/conversion"
    key_params: ["conversion_id", "conversion_label", "value"]

  meta_pixel:
    pattern: "facebook.com/tr"
    key_params: ["ev", "cd[*]", "ud[*]"]

  meta_capi:
    pattern: "graph.facebook.com/.*/events"
    key_params: ["event_name", "event_time", "user_data"]

  linkedin:
    pattern: "ads.linkedin.com"
    key_params: ["conversion_id"]

  tiktok:
    pattern: "analytics.tiktok.com"
    key_params: ["event", "properties"]

  snapchat:
    pattern: "tr.snapchat.com"
    key_params: ["e_par"]

  sgtm:
    pattern: "<custom-sgtm-domain>"
    key_params: ["v", "tid", "en"]
```

---

## Integration with Existing OpenClaw Phases

### Where Bowser Fits in the Build Flow

| OpenClaw Phase | Bowser Integration |
|---|---|
| **Phase 0: Scaffold** | Include Bowser skills + agents in plugin structure |
| **Phase 1: GTM** | Run Discovery Agent to auto-generate tag/trigger/variable configs |
| **Phase 2: Google Ads** | Run QA stories to validate conversion tag firing |
| **Phase 3: Meta** | Run QA stories to validate CAPI events + deduplication |
| **Phase 4: Wrappers** | Discovery Agent feeds openclaw-setup with site-specific configs |
| **Phase 5: Integration** | Full QA suite runs all stories across all platforms |

### New Phase: Phase 6 — Browser QA & Validation

This becomes an ongoing phase that runs after any GTM changes:

```
Phase 6: Browser Validation
├── Discovery scan (what needs tracking?)
├── GTM Preview validation (do tags fire?)
├── Conversion QA stories (do user journeys work?)
├── Network request audit (are payloads correct?)
└── Regression test suite (did anything break?)
```

---

## File Structure for the Plugin

```
openclaw-tracking-setup/
├── .claude/
│   ├── skills/
│   │   ├── openclaw-discovery/
│   │   │   └── SKILL.md          # Page scraping & opportunity identification
│   │   ├── openclaw-preview/
│   │   │   └── SKILL.md          # GTM Preview mode validation
│   │   └── openclaw-qa/
│   │       └── SKILL.md          # Conversion QA automation
│   ├── agents/
│   │   ├── discovery-agent.md     # Autonomous page analysis agent
│   │   ├── preview-agent.md       # GTM Preview validation agent
│   │   └── qa-agent.md           # YAML story execution agent
│   └── commands/
│       ├── discover.md            # Run discovery on a URL
│       ├── validate.md            # Run GTM Preview validation
│       ├── qa-run.md             # Execute QA stories
│       └── full-audit.md         # Discovery + Preview + QA pipeline
├── stories/                       # YAML QA story templates
│   ├── templates/
│   │   ├── lead-form.yaml
│   │   ├── ecommerce-purchase.yaml
│   │   ├── phone-click.yaml
│   │   ├── video-engagement.yaml
│   │   └── scroll-depth.yaml
│   └── clients/                   # Client-specific stories
│       └── .gitkeep
├── endpoints/
│   └── tracking-endpoints.yaml    # Network request patterns
└── reports/                       # Generated reports
    └── .gitkeep
```

---

## Claude Code Prompts for Building This

### Bowser Integration Phase Prompt

```
claude --dangerously-skip-permissions

You are building the browser automation layer for the OpenClaw tracking setup plugin.

## Context
Read these files first:
- PLANNING/BOWSER-OPENCLAW-INTEGRATION-PLAN.md (this plan)
- .claude/skills/ (existing skill structure from Organized Codebase)
- OPENCLAW-CLAUDE-CODE-PROMPTS.md (existing phase prompts)

## What to Build

### 1. Skills (.claude/skills/)

**openclaw-discovery/SKILL.md**
- Playwright-Bowser based page scraping skill
- Visits URLs, captures accessibility tree snapshots
- Classifies elements into tracking categories (forms, buttons, videos, links, scroll)
- Inspects dataLayer and existing tracking
- Outputs structured YAML discovery report

**openclaw-preview/SKILL.md**
- Chrome MCP based GTM Preview validation skill
- Pre-flight check for mcp__claude_in_chrome__* tools
- Reads dataLayer via javascript_tool
- Captures network requests filtered by tracking endpoints
- Checks console for tag errors
- Screenshots GTM Preview panel state

**openclaw-qa/SKILL.md**
- YAML story execution skill
- Reads story files from stories/ directory
- Executes steps sequentially (navigate, fill, click, wait)
- Validates dataLayer events, network requests, console state after each step
- Generates structured PASS/FAIL report with screenshots

### 2. Agents (.claude/agents/)

**discovery-agent.md** - Autonomous page crawler using openclaw-discovery skill
**preview-agent.md** - GTM Preview validation using openclaw-preview skill
**qa-agent.md** - YAML story executor using openclaw-qa skill

### 3. Commands (.claude/commands/)

**discover.md**: "Discover tracking opportunities on $ARGUMENTS"
**validate.md**: "Validate GTM Preview for $ARGUMENTS"
**qa-run.md**: "Run QA stories for $ARGUMENTS"
**full-audit.md**: "Run full discovery + validation + QA pipeline"

### 4. Story Templates (stories/templates/)
Create YAML templates for: lead-form, ecommerce-purchase, phone-click, video-engagement, scroll-depth

### 5. Endpoint Registry (endpoints/tracking-endpoints.yaml)
Define all known tracking endpoint patterns for network request filtering.

## Key Patterns from Bowser to Follow
- Skills are capabilities (single concern, reusable)
- Agents scale skills (autonomous, structured output)
- Commands orchestrate agents (user-facing entry points)
- YAML stories define test scenarios declaratively
- Always screenshot on failure
- Structured PASS/FAIL reporting

## Verification
After building, verify by:
1. Running discover command against a test URL
2. Checking that YAML story templates parse correctly
3. Confirming skill files follow Bowser's SKILL.md patterns
4. Confirming agents follow Bowser's agent.md patterns
```

### Environment Variables

```bash
# Standard OpenClaw env vars still apply
export GTM_ACCOUNT_ID="your-account-id"
export GTM_CONTAINER_ID="your-container-id"
export GTM_WORKSPACE_ID="your-workspace-id"

# Bowser-specific (optional)
export PLAYWRIGHT_MCP_VIEWPORT_SIZE="1440x900"
```

---

## Execution Order

| Order | Component | What It Does |
|---|---|---|
| 1 | `openclaw-discovery` skill | Define the page scraping capability |
| 2 | `discovery-agent` | Autonomous page analysis agent using the skill |
| 3 | `endpoints/tracking-endpoints.yaml` | Network request pattern registry |
| 4 | `stories/templates/*.yaml` | YAML story templates for common scenarios |
| 5 | `openclaw-qa` skill | YAML story execution capability |
| 6 | `qa-agent` | Autonomous QA agent using the skill |
| 7 | `openclaw-preview` skill | GTM Preview validation capability |
| 8 | `preview-agent` | GTM Preview validation agent |
| 9 | Commands (discover, validate, qa-run) | User-facing entry points |
| 10 | `full-audit` command | Complete pipeline orchestrator |

---

## Success Criteria

- [ ] Discovery Agent produces structured YAML report from any website URL
- [ ] QA stories execute end-to-end with PASS/FAIL per step
- [ ] GTM Preview validation captures actual tag firing evidence
- [ ] Network request analyzer correctly filters tracking endpoints
- [ ] Reports include screenshots and evidence for every assertion
- [ ] Story templates cover the 5 most common tracking scenarios
- [ ] Commands are callable from Claude Code as /discover, /validate, etc.
- [ ] Full audit pipeline chains discovery → implementation → validation
