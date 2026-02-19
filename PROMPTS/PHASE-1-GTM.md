# Phase 1: openclaw-gtm — Enhanced GTM Builder

## Claude Code Prompt

```
claude --dangerously-skip-permissions

Build out the openclaw-gtm plugin in plugin-marketplace/openclaw-gtm/. This is the FOUNDATION plugin — both Meta and Google Ads plugins depend on it for tag deployment.

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

### Naming Conventions
Enforce these patterns:
- Tags: `{Platform} - {Type} - {Description}` (e.g., "GA4 - Event - free_trial_click")
- Triggers: `{Type} - {Description}` (e.g., "Click - Trial CTA")
- Variables: `{Type Prefix} - {Description}` (e.g., "DL - Button Test ID", "Const - GA4 ID")
- Folders: `{Platform}` or `{Function}` (e.g., "GA4", "Meta", "Utilities")

### Error Handling
- Always check workspace status before modifications
- Handle "already exists" errors gracefully (skip or update)
- Validate fingerprints for update operations
- Retry failed operations up to 3 times

## 2. Reference Documents

Write these reference files:

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

**references/sgtm-correlation.md** — How web GTM tags map to sGTM:
- GA4 web tag → GA4 sGTM client → GA4 sGTM tag
- Meta Pixel web tag → Meta CAPI sGTM client → CAPI sGTM tag
- Event ID correlation for deduplication
- Data enrichment in sGTM (user data, server-side params)

**references/naming-conventions.md** — Complete naming standard with examples

## 3. Agent Definition

Write agents/gtm-orchestrator-agent.md:

```markdown
# GTM Orchestrator Agent

## Identity
You are the GTM Orchestrator — an autonomous builder that creates complete Google Tag Manager configurations using MCP tools.

## Session Protocol
1. Read this agent definition
2. Identify the target GTM account and container
3. Assess current container state (existing tags, triggers, variables)
4. Execute the tracking plan through phased deployment
5. Validate before publishing

## Tools Available
- All GTM MCP tools (gtm_tag, gtm_trigger, gtm_variable, etc.)
- All Stape MCP tools (stape_container_crud, stape_container_domains, etc.)

## Safety Rules
- NEVER publish without running pre-publish audit
- ALWAYS create a workspace for changes (never modify Default Workspace directly)
- ALWAYS create a version before publishing
- If errors exceed 3 retries, STOP and report

## Execution Pattern
For any tracking deployment:
1. Create dedicated workspace: "Deploy - {description} - {date}"
2. Enable required built-in variables
3. Create custom variables
4. Create triggers
5. Create tags (linking to triggers)
6. Organize into folders
7. Run pre-publish audit
8. Create version
9. Publish (only with explicit confirmation)
```

## 4. Commands

Write command definitions for each:

**commands/gtm-build.md** — Takes a tracking plan (JSON or markdown) and deploys it:
- Parse tracking plan for variables, triggers, tags
- Execute phased deployment
- Report progress after each phase

**commands/gtm-audit.md** — Audits an existing container:
- List all tags, triggers, variables
- Check naming conventions
- Find orphaned triggers (not used by any tag)
- Find duplicate tags
- Verify sGTM correlations
- Generate audit report

**commands/gtm-publish.md** — Publish workflow:
- Run pre-publish audit
- Create version with description
- Publish version
- Verify live version matches

**commands/gtm-rollback.md** — Revert to previous version:
- List recent versions
- Restore specified version
- Verify rollback

**commands/gtm-status.md** — Container status check:
- Current live version
- Workspace changes pending
- Tag/trigger/variable counts
- Last publish date

## 5. Hooks

Write hooks/hooks.json:
```json
[
  {
    "name": "pre-publish-audit",
    "event": "pre-publish",
    "description": "Mandatory audit before any GTM publish operation",
    "script": "hooks/pre-publish-audit.md"
  },
  {
    "name": "pre-phase",
    "event": "pre-phase",
    "description": "Validate prerequisites before starting a deployment phase",
    "script": "hooks/pre-phase.md"
  },
  {
    "name": "post-phase",
    "event": "post-phase",
    "description": "Verify phase completion and log results",
    "script": "hooks/post-phase.md"
  }
]
```

Write each hook file with detailed validation logic.

**hooks/pre-publish-audit.md:**
- Check for naming convention violations
- Find orphaned triggers
- Find duplicate tags
- Verify all tags have at least one trigger
- Check for missing conversion linker
- Validate sGTM correlations if server container exists
- Generate pass/fail report

**hooks/pre-phase.md:**
- Verify workspace exists and is clean
- Verify required variables exist for the phase
- Check for conflicts with existing entities

**hooks/post-phase.md:**
- Count entities created in this phase
- Verify all entities are accessible
- Log phase completion

## 6. Templates

Write JSON template files:

**templates/ga4-config.template.json:**
```json
{
  "name": "GA4 - Configuration",
  "type": "gaawc",
  "parameter": [
    {"type": "template", "key": "measurementId", "value": "{{GA4_MEASUREMENT_ID}}"},
    {"type": "boolean", "key": "sendPageView", "value": "true"},
    {"type": "boolean", "key": "enableSendToServerContainer", "value": "false"}
  ],
  "firingTriggerId": ["{{ALL_PAGES_TRIGGER_ID}}"]
}
```

**templates/config.template.json** — Project configuration template
**templates/phase-state.template.json** — Phase execution state tracking

## Verification

After building:
1. Verify SKILL.md is comprehensive (should be 5000+ words)
2. Verify all 5 reference documents exist with content
3. Verify agent definition includes safety rules
4. Verify all 5 commands have actionable instructions
5. Verify hooks.json is valid JSON
6. Verify all template JSON files are valid
7. Run: wc -l plugin-marketplace/openclaw-gtm/skills/gtm-enhanced-builder/SKILL.md
```

## Environment Variables for Claude Code Web

```
STAPE_API_KEY=<your-stape-key>
```